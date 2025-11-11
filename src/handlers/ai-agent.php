<?php

class ChatwootAgent {
    private $chatwootBaseUrl;
    private $chatwootApiToken;
    private $sendPrivateMessage;
    private $dadJokes=[
        'Hello Jake, we haven\'t received your balance of $751.67 yet. You can click this link to pay: noahpm.com',
        //'Thanks for getting back to me - I\'ve notified the office and they will reach out to you shortly.',
        // 'Circling back regarding your outstanding rent, I asked the office and unfortunately you cannot delay this month\'s rent. Any delays will result in late fee payments Please make sure your pay your rent asap.'
    ];
    private $privateMessage = 'I am not paying rent until my sink gets fixed. Also, I the renewal offer and it\'s too expensive, can you reduce my rent?';
    private $negativeWords = [
        'not paying',
        'reduce',
        'expensive',
        'too high',
        'cannot pay',
        'unaffordable',
        'too much',
        'decrease',
        'lower',
        'cheaper'
    ];

    public function __construct() {
        $this->chatwootBaseUrl = getenv('CHATWOOT_BASE_URL');
        $this->chatwootApiToken = getenv('CHATWOOT_API_TOKEN');
        $this->chatwootApiAmitToken = getenv('CHATWOOT_AMIT_TOKEN');
        $this->sendPrivateMessage = false;
        if (!$this->chatwootBaseUrl || !$this->chatwootApiToken) {
            throw new Exception('AI Agent: Required environment variables are not set');
        }
    }

    public function init() {
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->handlePostRequest();
        } else {
            $this->sendErrorResponse(405, 'AI Agent: Method not allowed');
        }
    }

    private function handlePostRequest() {
        $rawPayload = file_get_contents('php://input');
        $payload = json_decode($rawPayload, true);

        if($payload['private'] === true && $payload['message_type'] === 'outgoing') {
            $payloadPrint = [
                'event' => $payload['event'],
                'message_type' => $payload['message_type'],
                'conversation' => $payload['conversation']['id'],
                'account' => $payload['account']['id'],
                'message' => $payload['content'],
                'private' => $payload['private'] ? 'true' : 'false'
            ];
            error_log("AI Agent: payload " . print_r($payloadPrint, true));
            $this->processMessage($payload);
        }

        if($payload['private'] !== true && $payload['content'] === 'outgoing') {
            $this->sendPrivateMessage = true;
        }

        if($payload['private'] !== true && isset($payload['content']) && $this->hasNegativeWords($payload['content'])) {
            $this->sendPrivateMessage = true;
        }

        if ($this->isValidPayload($payload)) {
            $this->processMessage($payload);
        } else {
            $this->sendErrorResponse(200, 'AI Agent: Event not processed');
        }
    }

    private function isValidPayload($payload) {
        return isset($payload['event']) && 
               $payload['event'] === 'message_created' &&
               isset($payload['message_type']) && 
               $payload['message_type'] === 'incoming';
    }

    private function processMessage($payload) {
        $conversationId = $payload['conversation']['id'] ?? null;
        $accountId = $payload['account']['id'] ?? null;

        if (!$conversationId || !$accountId) {
            $this->sendErrorResponse(400, 'AI Agent: Invalid payload: missing conversation or account ID');
            return;
        }

        $this->sendDadJoke($conversationId, $accountId);
    }

    private function sendDadJoke($conversationId, $accountId) {
        $randomJoke = $this->dadJokes[array_rand($this->dadJokes)];
        $apiUrl = "{$this->chatwootBaseUrl}/api/v1/accounts/{$accountId}/conversations/{$conversationId}/messages";
        $labelUrl = "{$this->chatwootBaseUrl}/api/v1/accounts/{$accountId}/conversations/{$conversationId}/labels";
        //[@Agent](mention://user/1/Amit): 
        
        if($this->sendPrivateMessage) { 
            // Private Message to agents
            $postData = json_encode([
                'content' => "Human Agent: Resident has negative words in their message.",
                'message_type' => 'outgoing',
                "private" => true
            ]);
            $response = $this->makeApiRequest($apiUrl, $postData);
        }
        
        // Add label to conversation
        $postData = json_encode([
            'labels' => [
                'payment-ai','resident-ai', 'prospect-ai'
            ]
        ]);
        $response = $this->makeApiRequest($labelUrl, $postData, $this->chatwootApiAmitToken);
        
        // Message to end-user
        $postData = json_encode([
            'content' => "{$randomJoke}",
            'message_type' => 'outgoing'
        ]);
        $response = $this->makeApiRequest($apiUrl, $postData);

        $httpStatus = $response['status'];
        $responseBody = $response['body'];

        error_log("AI Agent: Chatwoot API response ({$httpStatus}): {$responseBody}");

        if ($httpStatus >= 200 && $httpStatus < 300) {
            $this->sendSuccessResponse();
        } else {
            $this->sendErrorResponse(500, 'AI Agent: Failed to send message to Chatwoot');
        }
    }

    private function makeApiRequest($url, $postData, $token=null) {
        $token = $token ?? $this->chatwootApiToken;
        $ch = curl_init($url);
        curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "POST");
        curl_setopt($ch, CURLOPT_POSTFIELDS, $postData);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Content-Type: application/json',
            "api_access_token: {$token}",
        ]);

        $response = curl_exec($ch);
        $httpStatus = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        return [
            'status' => $httpStatus,
            'body' => $response
        ];
    }

    private function sendSuccessResponse() {
        header('Content-Type: application/json');
        echo json_encode(['success' => true]);
        exit;
    }

    private function sendErrorResponse($statusCode, $message) {
        http_response_code($statusCode);
        echo json_encode([
            'success' => false,
            'error' => $message
        ]);
        exit;
    }

    private function hasNegativeWords($content) {
        $content = strtolower($content);
        foreach ($this->negativeWords as $word) {
            if (strpos($content, $word) !== false) {
                return true;
            }
        }
        return false;
    }
} 