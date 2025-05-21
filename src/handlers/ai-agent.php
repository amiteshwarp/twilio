<?php

class ChatwootAgent {
    private $chatwootBaseUrl;
    private $chatwootApiToken;
    private $dadJokes = [
        "Why don't eggs tell jokes? They'd crack up!",
        "What do you call a fake noodle? An impasta!",
        "Why did the scarecrow win an award? Because he was outstanding in his field!",
        "Why don't skeletons fight each other? They don't have the guts!",
        "What do you call a bear with no teeth? A gummy bear!",
        "What do you call cheese that isn't yours? Nacho cheese!",
        "Why did the cookie go to the doctor? Because it was feeling crumbly!",
        "What do you call a can opener that doesn't work? A can't opener!",
        "Why did the golfer bring two pairs of pants? In case he got a hole in one!",
        "What do you call a pig that does karate? A pork chop!",
        "Why don't scientists trust atoms? Because they make up everything!",
        "What do you call a fish wearing a bowtie? So-fish-ticated!",
        "What do you get when you cross a snowman with a vampire? Frostbite!",
        "Why did the math book look so sad? Because it had too many problems!",
        "What do you call a bear with no ears? B!",
        "Why don't oysters donate to charity? Because they're shellfish!",
        "What did the grape say when it got stepped on? Nothing, it just let out a little wine!",
        "Why don't eggs tell each other secrets? Because they might crack up!",
        "What do you call a sleeping bull? A bulldozer!",
        "Why did the gym close down? It just didn't work out!",
        "What do you call a pile of cats? A meow-ntain!",
        "Why don't melons get married? They cantaloupe!",
        "What did the buffalo say to his son when he left? Bison!",
        "Why did the cookie go to the nurse? Because it was feeling crumbly!",
        "What do you call a dinosaur that crashes his car? Tyrannosaurus wrecks!",
        "Why don't ants get sick? Because they have tiny ant-ibodies!",
        "What kind of tree fits in your hand? A palm tree!",
        "Why did the jellybean go to school? To become a smartie!",
        "What do you call a dog magician? A labracadabrador!",
        "Why did the bicycle fall over? Because it was two-tired!",
        "What did the ocean say to the shore? Nothing, it just waved!",
        "Why don't basketball players tell jokes during the game? They might crack up!",
        "What do you call a duck that gets all A's? A wise quacker!",
        "Why did the cookie go to the doctor? Because it was feeling crumbly!",
        "What do you call a sheep with no legs? A cloud!",
        "Why did the scarecrow become a successful motivational speaker? He was outstanding in his field!",
        "What do you call a cow with no legs? Ground beef!",
        "Why did the belt go to jail? For holding up pants!",
        "What do you call a fish wearing a crown? King salmon!",
        "Why did the math teacher break up with the calculator? Because there were too many problems!",
        "What do you call a lazy kangaroo? A pouch potato!",
        "Why did the cookie go to therapy? It was feeling crumbly!",
        "What do you call a bear with no teeth? A gummy bear!",
        "Why did the stadium get hot after the game? All the fans left!",
        "What do you call a snowman with a six-pack? An abdominal snowman!",
        "Why did the pizza maker go broke? Because he just couldn't make enough dough!",
        "What do you call a fake stone in Ireland? A sham rock!",
        "Why did the gardener plant light bulbs? They wanted to grow a power plant!",
        "What do you call a cow during an earthquake? A milkshake!",
        "Why did the cookie go to the hospital? Because it felt crumbly!"
    ];

    public function __construct() {
        $this->chatwootBaseUrl = getenv('CHATWOOT_BASE_URL');
        $this->chatwootApiToken = getenv('CHATWOOT_API_TOKEN');
        
        if (!$this->chatwootBaseUrl || !$this->chatwootApiToken) {
            throw new Exception('Required environment variables are not set');
        }
    }

    public function init() {
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->handlePostRequest();
        } else {
            $this->sendErrorResponse(405, 'Method not allowed');
        }
    }

    private function handlePostRequest() {
        $rawPayload = file_get_contents('php://input');
        $payload = json_decode($rawPayload, true);

        error_log('Incoming Chatwoot webhook payload: ' . print_r($payload, true));

        if ($this->isValidPayload($payload)) {
            $this->processMessage($payload);
        } else {
            $this->sendErrorResponse(200, 'Event not processed');
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
            $this->sendErrorResponse(400, 'Invalid payload: missing conversation or account ID');
            return;
        }

        $this->sendDadJoke($conversationId, $accountId);
    }

    private function sendDadJoke($conversationId, $accountId) {
        $randomJoke = $this->dadJokes[array_rand($this->dadJokes)];
        $apiUrl = "{$this->chatwootBaseUrl}/api/v1/accounts/{$accountId}/conversations/{$conversationId}/messages";
        $labelUrl = "{$this->chatwootBaseUrl}/api/v1/accounts/{$accountId}/conversations/{$conversationId}/labels";
        //[@Agent](mention://user/1/Amit): 
        
        // Private Message to agents
        $postData = json_encode([
            'content' => "Private message for you!",
            'message_type' => 'outgoing',
            "private" => true
        ]);
        $response = $this->makeApiRequest($apiUrl, $postData);
        
        // Add label to conversation
        $postData = json_encode([
            'labels' => [
                'payment-ai','resident-ai', 'prospect-ai'
            ]
        ]);
        $response = $this->makeApiRequest($labelUrl, $postData);
        
        // Message to end-user
        $postData = json_encode([
            'content' => "Here's a dad joke for you: {$randomJoke}",
            'message_type' => 'outgoing'
        ]);
        $response = $this->makeApiRequest($apiUrl, $postData);

        $httpStatus = $response['status'];
        $responseBody = $response['body'];

        error_log("Chatwoot API response ({$httpStatus}): {$responseBody}");

        if ($httpStatus >= 200 && $httpStatus < 300) {
            $this->sendSuccessResponse();
        } else {
            $this->sendErrorResponse(500, 'Failed to send message to Chatwoot');
        }
    }

    private function makeApiRequest($url, $postData) {
        $ch = curl_init($url);
        curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "POST");
        curl_setopt($ch, CURLOPT_POSTFIELDS, $postData);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Content-Type: application/json',
            "api_access_token: {$this->chatwootApiToken}",
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
} 