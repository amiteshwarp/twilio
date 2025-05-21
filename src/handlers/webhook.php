<?php

class ChatwootWebhook {
    private $requestBody;
    private $data;
    private $headers;
    private $commsKey;

    public function __construct() {
        $this->init();
        $this->requestBody = file_get_contents('php://input');
        $this->data = json_decode($this->requestBody, true);
        $this->headers = apache_request_headers();
        $this->commsKey = getenv('CHATWOOT_COMMS_KEY');
        
        if (!$this->commsKey) {
            throw new Exception('CHATWOOT_COMMS_KEY environment variable is not set');
        }
    }

    private function init() {
        // Initialize the webhook handler
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->handleWebhook();
        } else {
            $this->sendErrorResponse(405, 'Method not allowed');
        }
    }

    private function handleWebhook() {
        //$this->logHeaders();
        
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
        
        $this->sendSuccessResponse();
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