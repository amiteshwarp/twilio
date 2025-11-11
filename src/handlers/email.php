<?php

class SendGridEmailWebhook {
    private $requestBody;
    private $data;
    private $headers;
    private $apiKey;
    private $webhookType; // 'event' or 'inbound'

    public function __construct() {
        // $this->apiKey = getenv('SENDGRID_API_KEY');
        
        // if (!$this->apiKey) {
        //     throw new Exception('SENDGRID_API_KEY environment variable is not set');
        // }
        $this->init();
        $this->headers = apache_request_headers();
    }

    public function init() {
        // Initialize the webhook handler
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->handleWebhook();
        } else {
            $this->sendErrorResponse(405, 'Email: Method not allowed');
        }
    }

    private function handleWebhook() {
        // $this->logHeaders();
        
        // Log both POST data and raw body for debugging
        error_log("=== WEBHOOK DEBUG START ===");
        error_log("Request Method: " . $_SERVER['REQUEST_METHOD']);
        error_log("Content-Type: " . ($_SERVER['CONTENT_TYPE'] ?? 'not set'));
        error_log("POST Data Keys: " . implode(', ', array_keys($_POST)));
        error_log("POST Data: " . print_r($_POST, true));
        
        // For multipart/form-data, $_POST will contain the data and php://input will be empty
        // For JSON requests, php://input will contain the data
        $this->requestBody = file_get_contents('php://input');
        error_log("Raw Request Body Length: " . strlen($this->requestBody));
        error_log("Raw Request Body: " . $this->requestBody);
        error_log("=== WEBHOOK DEBUG END ===");
        
        // Determine webhook type based on content
        $this->determineWebhookType();
        
        if ($this->webhookType === 'inbound') {
            $this->handleInboundWebhook();
        } else {
            $this->handleEventWebhook();
        }
    }

    private function determineWebhookType() {
        // Check if it's an inbound parse webhook (multipart/form-data)
        if (!empty($_POST)) {
            error_log("POST data is not empty, checking for email field...");
            if (isset($_POST['email'])) {
                $this->webhookType = 'inbound';
                error_log("Detected Inbound Parse webhook - email field found");
            } else {
                error_log("POST data exists but no 'email' field found. Available fields: " . implode(', ', array_keys($_POST)));
                // Try to parse as JSON (event webhook)
                $this->data = json_decode($this->requestBody, true);
                if ($this->data && is_array($this->data)) {
                    $this->webhookType = 'event';
                    error_log("Detected Event webhook from JSON");
                } else {
                    error_log("Failed to detect webhook type");
                    error_log("POST data: " . print_r($_POST, true));
                    error_log("Raw body: " . $this->requestBody);
                    $this->sendErrorResponse(400, 'Invalid webhook payload - neither inbound nor event format');
                }
            }
        } else {
            // No POST data, try JSON
            error_log("No POST data, trying JSON parsing...");
            $this->data = json_decode($this->requestBody, true);
            if ($this->data && is_array($this->data)) {
                $this->webhookType = 'event';
                error_log("Detected Event webhook from JSON");
            } else {
                error_log("Failed to detect webhook type");
                error_log("POST data: " . print_r($_POST, true));
                error_log("Raw body: " . $this->requestBody);
                $this->sendErrorResponse(400, 'Invalid webhook payload - neither inbound nor event format');
            }
        }
    }

    private function handleInboundWebhook() {
        error_log("Received SendGrid Inbound Parse webhook");
        
        // Extract data from POST
        $raw_email_content = $_POST['email'] ?? null;
        $from_email = $_POST['from'] ?? null;
        $to_email = $_POST['to'] ?? null;
        $subject = $_POST['subject'] ?? null;
        $charsets = $_POST['charsets'] ?? null;
        $spam_report = $_POST['spam_report'] ?? null;
        $spam_score = $_POST['spam_score'] ?? null;

        if (!$raw_email_content) {
            $this->sendErrorResponse(400, 'No email content received from SendGrid Inbound Parse');
        }

        // Log the raw email for debugging
        file_put_contents('sendgrid_inbound_log.txt', date('Y-m-d H:i:s') . " - Incoming Email:\n" . $raw_email_content . "\n\n", FILE_APPEND);

        // Prepare payload for external webhook
        $payload = [
            'messageId' => uniqid('sg_inbound_'),
            'source' => $from_email,
            'destination' => $to_email,
            'subject' => $subject,
            'raw_email_content' => $raw_email_content,
            'webhook_type' => 'inbound_parse',
            'sendgrid_metadata' => [
                'spam_report' => $spam_report,
                'spam_score' => $spam_score,
                'charsets' => $charsets,
                'received_at' => date('c')
            ]
        ];

        // Forward to external webhook if configured
        if (getenv('EXTERNAL_EMAIL_WEBHOOK_URL')) {
            $this->forwardToExternalWebhook($payload);
        }

        $this->sendSuccessResponse();
    }

    private function handleEventWebhook() {
        error_log("Received SendGrid Event webhook");
        error_log(json_encode($this->data, JSON_PRETTY_PRINT));
        
        // Process each event in the webhook payload
        foreach ($this->data as $event) {
            $this->processEmailEvent($event);
        }
        
        $this->sendSuccessResponse();
    }

    private function isValidPayload() {
        return $this->data && is_array($this->data) && !empty($this->data);
    }

    private function processEvent() {
        error_log("Received SendGrid email webhook event");
        error_log(json_encode($this->data, JSON_PRETTY_PRINT));
        
        // Process each event in the webhook payload
        foreach ($this->data as $event) {
            $this->processEmailEvent($event);
        }
        
        $this->sendSuccessResponse();
    }

    private function processEmailEvent($event) {
        $eventType = isset($event['event']) ? $event['event'] : 'unknown';
        $email = isset($event['email']) ? $event['email'] : 'unknown';
        $timestamp = isset($event['timestamp']) ? $event['timestamp'] : time();
        
        error_log("Processing SendGrid event: {$eventType} for email: {$email}");
        
        // Handle different event types
        switch ($eventType) {
            case 'delivered':
                $this->handleDelivered($event);
                break;
            case 'open':
                $this->handleOpen($event);
                break;
            case 'click':
                $this->handleClick($event);
                break;
            case 'bounce':
                $this->handleBounce($event);
                break;
            case 'dropped':
                $this->handleDropped($event);
                break;
            case 'spamreport':
                $this->handleSpamReport($event);
                break;
            case 'unsubscribe':
                $this->handleUnsubscribe($event);
                break;
            case 'group_unsubscribe':
                $this->handleGroupUnsubscribe($event);
                break;
            case 'group_resubscribe':
                $this->handleGroupResubscribe($event);
                break;
            default:
                error_log("Unhandled SendGrid event type: {$eventType}");
                break;
        }
        
        // Forward the event to external webhook if configured
        if (getenv('EXTERNAL_EMAIL_WEBHOOK_URL')) {
            $this->forwardToExternalWebhook($event);
        }
    }

    private function handleDelivered($event) {
        error_log("Email delivered: " . json_encode($event));
        // Add your delivery handling logic here
    }

    private function handleOpen($event) {
        error_log("Email opened: " . json_encode($event));
        // Add your open tracking logic here
    }

    private function handleClick($event) {
        error_log("Email link clicked: " . json_encode($event));
        // Add your click tracking logic here
    }

    private function handleBounce($event) {
        error_log("Email bounced: " . json_encode($event));
        // Add your bounce handling logic here
    }

    private function handleDropped($event) {
        error_log("Email dropped: " . json_encode($event));
        // Add your drop handling logic here
    }

    private function handleSpamReport($event) {
        error_log("Email marked as spam: " . json_encode($event));
        // Add your spam report handling logic here
    }

    private function handleUnsubscribe($event) {
        error_log("User unsubscribed: " . json_encode($event));
        // Add your unsubscribe handling logic here
    }

    private function handleGroupUnsubscribe($event) {
        error_log("User unsubscribed from group: " . json_encode($event));
        // Add your group unsubscribe handling logic here
    }

    private function handleGroupResubscribe($event) {
        error_log("User resubscribed to group: " . json_encode($event));
        // Add your group resubscribe handling logic here
    }

    private function forwardToExternalWebhook($data) {
        $postData = json_encode($data);
        $response = $this->makeApiRequest(getenv('EXTERNAL_EMAIL_WEBHOOK_URL'), $postData);
        
        $httpStatus = $response['status'];
        $responseBody = $response['body'];

        error_log("External webhook response ({$httpStatus}): {$responseBody}");

        if ($httpStatus < 200 || $httpStatus >= 300) {
            error_log("Failed to forward event to external webhook: {$httpStatus}");
        }
    }

    private function makeApiRequest($url, $postData) {
        $ch = curl_init($url);
        curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "POST");
        curl_setopt($ch, CURLOPT_POSTFIELDS, $postData);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Content-Type: application/json'
        ]);

        $response = curl_exec($ch);
        $httpStatus = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        return [
            'status' => $httpStatus,
            'body' => $response
        ];
    }

    private function logHeaders() {
        foreach ($this->headers as $header => $value) {
            error_log(json_encode([
                'header' => $header,
                'value' => $value
            ], JSON_PRETTY_PRINT));
        }
    }

    private function sendSuccessResponse() {
        http_response_code(200);
        echo json_encode(['status' => 'success']);
    }

    private function sendErrorResponse($statusCode, $message) {
        http_response_code($statusCode);
        error_log($message);
        echo json_encode(['error' => $message]);
        exit;
    }

    // Optional validation methods
    private function validateUserAgent() {
        if(stripos($_SERVER['HTTP_USER_AGENT'], 'sendgrid') === false) {
            $this->sendErrorResponse(403, 'Webhook rejected: Invalid user agent.');
        }
    }

    private function validateSignature() {
        // Implement SendGrid signature validation if needed
        // This would verify the webhook signature using your SendGrid API key
        if (isset($this->headers['X-Twilio-Email-Event-Webhook-Signature'])) {
            // Add signature validation logic here
            // $signature = $this->headers['X-Twilio-Email-Event-Webhook-Signature'];
            // $timestamp = $this->headers['X-Twilio-Email-Event-Webhook-Timestamp'];
            // $payload = $this->requestBody;
            // Verify signature using SendGrid's validation method
        }
    }
}

// Initialize the webhook handler
$webhook = new SendGridEmailWebhook();
?> 