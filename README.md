# Twilio Webhook with Docker & ngrok

This project provides a **fully containerized** PHP webhook server that can receive **Twilio callbacks**, modify the data by adding a custom key-value pair, and forward the request to an **external webhook**.

The setup includes:
- A PHP-based webhook handler.
- Automatic **ngrok** tunneling to expose the webhook publicly.
- **Dockerized** environment for easy deployment and testing.

---

## **Prerequisites**

Before running the project, make sure you have:

- **Docker & Docker Compose** installed ([Download Docker](https://www.docker.com/get-started))
- **A Twilio Account** ([Sign up here](https://www.twilio.com/try-twilio))
- **ngrok Authentication Token** ([Get your token](https://dashboard.ngrok.com/get-started/your-authtoken))

---

## **Getting Started**

### **1. Clone the Repository**
```bash
git clone https://github.com/your-repo/twilio-webhook-docker.git
cd twilio-webhook-docker
```

### **2. Add Your ngrok Auth Token**
Edit the `ngrok.yml` file and replace `YOUR_NGROK_AUTH_TOKEN` with your **ngrok authentication token**.
```yaml
authtoken: YOUR_NGROK_AUTH_TOKEN
tunnels:
  http:
    proto: http
    addr: 5000
```

### **3. Build the Docker Image**
```bash
docker build -t twilio-webhook .
```

### **4. Run the Docker Container**
```bash
docker run -d --name twilio-webhook -p 5000:5000 -p 4040:4040 twilio-webhook
```

### **5. Get the Public URL from ngrok**
Run the following command to get the **ngrok forwarding URL**:
```bash
docker logs twilio-webhook
```
Look for a line like:
```
Forwarding    https://xyz.ngrok.io -> http://localhost:5000
```
Copy the `https://xyz.ngrok.io` URL.

### **6. Configure Twilio Webhook**
1. Log in to **Twilio Console**
2. Navigate to **Phone Numbers** > **Manage Numbers**
3. Select your phone number
4. Under **Messaging** or **Voice Webhook**, set:
   - **Webhook URL** → `https://xyz.ngrok.io/webhook.php`
   - **Method** → `POST`
5. Save changes

---

## **How It Works**

1. Twilio sends incoming webhook requests to `https://xyz.ngrok.io/webhook.php`.
2. The PHP script:
   - Receives Twilio’s data.
   - Adds a custom key-value pair.
   - Forwards the modified data to `https://external.webhook.com`.
3. Logs the incoming and forwarded data to `log.txt`.

---

## **Testing the Webhook**
To test, send an **SMS to your Twilio number** and check the logs:
```bash
docker exec -it twilio-webhook cat /var/www/html/log.txt
```
You should see the received and modified payload.

---

## **Stopping & Restarting**
To stop the container:
```bash
docker stop twilio-webhook && docker rm twilio-webhook
```

To restart the container:
```bash
docker run -d --name twilio-webhook -p 5000:5000 -p 4040:4040 twilio-webhook
```

---

## **Customization**
- Modify `webhook.php` to change how data is handled.
- Update `ngrok.yml` to change tunnel settings.
- Use `docker-compose.yml` for a more advanced setup.

---

## **Troubleshooting**

- **Error: ngrok not starting?**
  - Ensure your **auth token** is correct in `ngrok.yml`.

- **Webhook not receiving requests?**
  - Check `docker logs twilio-webhook` for errors.
  - Ensure your Twilio number is configured correctly.

---

## **Contributing**
Feel free to fork and submit pull requests to improve the project!

---

## **License**
This project is open-source and available under the **MIT License**.


graph TD

    636["User<br>External Actor"]
    subgraph 622["External Systems"]
        633["Chatwoot Platform<br>Chatwoot"]
        634["Twilio Cloud APIs<br>Twilio"]
        635["Application Database<br>SQL"]
    end
    subgraph 623["Webhook Service<br>Container Runtime"]
        632["Webhook Receiver<br>Custom Runtime"]
    end
    subgraph 624["Phone Integration Service<br>Container Runtime"]
        631["Phone Call Processor<br>Custom Runtime"]
    end
    subgraph 625["Main Application<br>PHP, JavaScript, HTML"]
        626["Frontend Assets<br>Code Directory"]
        627["Application Entry<br>PHP"]
        628["API &amp; Request Handlers<br>PHP"]
        %% Edges at this level (grouped by source)
        627["Application Entry<br>PHP"] -->|serves / routes to| 626["Frontend Assets<br>Code Directory"]
        627["Application Entry<br>PHP"] -->|routes to| 628["API &amp; Request Handlers<br>PHP"]
    end
    %% Edges at this level (grouped by source)
    636["User<br>External Actor"] -->|interacts with| 627["Application Entry<br>PHP"]
    632["Webhook Receiver<br>Custom Runtime"] -->|relays events to| 628["API &amp; Request Handlers<br>PHP"]
    632["Webhook Receiver<br>Custom Runtime"] -->|logs to| 635["Application Database<br>SQL"]
    633["Chatwoot Platform<br>Chatwoot"] -->|sends webhooks to| 628["API &amp; Request Handlers<br>PHP"]
    628["API &amp; Request Handlers<br>PHP"] -->|delegates voice logic to| 631["Phone Call Processor<br>Custom Runtime"]
    628["API &amp; Request Handlers<br>PHP"] -->|uses AI agent via| 633["Chatwoot Platform<br>Chatwoot"]
    628["API &amp; Request Handlers<br>PHP"] -->|initiates calls/SMS via| 634["Twilio Cloud APIs<br>Twilio"]
    628["API &amp; Request Handlers<br>PHP"] -->|persists data to| 635["Application Database<br>SQL"]
    634["Twilio Cloud APIs<br>Twilio"] -->|sends event webhooks to| 632["Webhook Receiver<br>Custom Runtime"]
    631["Phone Call Processor<br>Custom Runtime"] -->|interacts with| 634["Twilio Cloud APIs<br>Twilio"]
    631["Phone Call Processor<br>Custom Runtime"] -->|accesses| 635["Application Database<br>SQL"]
    626["Frontend Assets<br>Code Directory"] -->|integrates with| 633["Chatwoot Platform<br>Chatwoot"]
