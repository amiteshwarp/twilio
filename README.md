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


