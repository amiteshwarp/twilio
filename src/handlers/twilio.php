<?php

class TwilioWebhook {
    private $postData;
    private $parsedData;
    private $headers;
    private $externalWebhookUrl;

    public function __construct() {
        $this->postData = file_get_contents("php://input");
        $this->parsedData = [];
        parse_str($this->postData, $this->parsedData);
        $this->headers = apache_request_headers();
        $this->externalWebhookUrl = getenv('EXTERNAL_WEBHOOK_URL');
        
        if (!$this->externalWebhookUrl) {
            throw new Exception('EXTERNAL_WEBHOOK_URL environment variable is not set');
        }
    }

    public function init() {
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->handleWebhook();
        } else {
            $this->sendErrorResponse(405, 'Twilio:Method not allowed');
        }
    }

    private function handleWebhook() {
        $this->logHeaders();
        $this->processData();
        $this->forwardToExternalWebhook();
        $this->sendSuccessResponse();
    }

    private function processData() {
        foreach ($this->parsedData as $k => $v) {
            $keyDecoded = json_decode($k, true);
            $valDecoded = [];

            foreach ($v as $ik => $iv) {
                $valDecoded[] = json_decode($ik, true);
            }

            error_log(json_encode([
                'key' => $keyDecoded,
                'messages' => $valDecoded
            ], JSON_PRETTY_PRINT));
        }
    }

    private function logHeaders() {
        foreach ($this->headers as $header => $value) {
            error_log(json_encode([
                'header' => $header,
                'value' => $value
            ], JSON_PRETTY_PRINT));
        }
    }

    private function forwardToExternalWebhook() {
        $ch = curl_init($this->externalWebhookUrl);
        curl_setopt($ch, CURLOPT_POST, 1);
        curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query($this->parsedData));
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        
        $response = curl_exec($ch);
        $httpStatus = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        // Log the response
        error_log("External webhook response ({$httpStatus}): {$response}");
    }

    private function sendSuccessResponse() {
        echo "Webhook processed and forwarded!";
    }

    private function sendErrorResponse($statusCode, $message) {
        http_response_code($statusCode);
        error_log($message);
        exit;
    }

    // Optional method to add custom data to the parsed data
    private function addCustomData($key, $value) {
        $this->parsedData[$key] = $value;
    }
} 