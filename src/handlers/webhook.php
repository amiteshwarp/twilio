<?php

class ChatwootWebhook {
    private $requestBody;
    private $data;
    private $headers;
    private $commsKey;

    public function __construct() {
        // $this->commsKey = getenv('CHATWOOT_COMMS_KEY');
        
        // if (!$this->commsKey) {
        //     throw new Exception('CHATWOOT_COMMS_KEY environment variable is not set');
        // }
        $this->init();
        $this->headers = apache_request_headers();
    }

    public function init() {
        // Initialize the webhook handler
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->handleWebhook();
        } else {
            $this->sendErrorResponse(405, 'Webhook: Method not allowed');
        }
    }

    private function handleWebhook() {
        //$this->logHeaders();
        $this->requestBody = file_get_contents('php://input');
        $this->data = json_decode($this->requestBody, true);

        if ($this->isValidPayload()) {
            $this->processEvent();
        } else {
            $this->sendErrorResponse(400, 'Invalid Chatwoot webhook payload or missing event field');
        }
    }

    private function isValidPayload() {
        return $this->data && isset($this->data['event']);
    }

    private function processEvent() {
        $eventName = $this->data['event'];
        error_log("Received Chatwoot event: " . $eventName);
        error_log(json_encode($this->data, JSON_PRETTY_PRINT));
        //file_put_contents('/tmp/input.txt', json_encode($this->data, JSON_PRETTY_PRINT), FILE_APPEND);
        $postData = json_encode($this->data);
        $response = $this->makeApiRequest(getenv('EXTERNAL_WEBHOOK_URL'), $postData);
        
        $httpStatus = $response['status'];
        $responseBody = $response['body'];

        error_log("Chatwoot API response ({$httpStatus}): {$responseBody}");

        if ($httpStatus >= 200 && $httpStatus < 300) {
            $this->sendSuccessResponse();
        } else {
            $this->sendErrorResponse(500, 'Failed to send message to Webhook, Error:' . $httpStatus);
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
    }

    private function sendErrorResponse($statusCode, $message) {
        http_response_code($statusCode);
        error_log($message);
        exit;
    }

    // Optional validation methods (currently commented out in original code)
    private function validateUserAgent() {
        if(stripos($_SERVER['HTTP_USER_AGENT'], 'ruby') === false) {
            $this->sendErrorResponse(403, 'Webhook rejected: Invalid user agent.');
        }
    }

    private function validateCommsKey() {
        if(!isset($_REQUEST['comms']) || $_REQUEST['comms'] !== $this->commsKey) {
            $this->sendErrorResponse(403, 'Webhook rejected: Invalid comms key.');
        }
    }
} 