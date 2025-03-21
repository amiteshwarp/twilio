<?php
// webhook.php - Twilio Webhook Handler & Forwarder

// Load environment variables from .env file
if (file_exists(__DIR__ . '/.env')) {
    $lines = file(__DIR__ . '/.env', FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        if (strpos(trim($line), '#') === 0) continue; // Ignore comments
        putenv($line);
    }
}

// Get incoming Twilio POST data
$postData = file_get_contents("php://input");
parse_str($postData, $parsedData);

// Add a custom key-value pair
$parsedData['custom_key'] = 'custom_value';

// Forward the modified data to another webhook
$externalWebhookUrl = getenv('EXTERNAL_WEBHOOK_URL');

// Log received and modified data
file_put_contents("log.txt", print_r($parsedData, true), FILE_APPEND);
file_put_contents("log.txt", print_r($externalWebhookUrl, true), FILE_APPEND);


$ch = curl_init($externalWebhookUrl);

curl_setopt($ch, CURLOPT_POST, 1);
curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query($parsedData));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

$response = curl_exec($ch);
curl_close($ch);

// Log the response from the external webhook
file_put_contents("log.txt", "\nResponse: " . $response . "\n", FILE_APPEND);

// Respond to Twilio
echo "Webhook processed and forwarded!";