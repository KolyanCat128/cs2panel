package com.example.cs2panel.bots.service;

import jakarta.annotation.PostConstruct;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.telegram.telegrambots.bots.TelegramLongPollingBot;
import org.telegram.telegrambots.meta.TelegramBotsApi;
import org.telegram.telegrambots.meta.api.methods.send.SendMessage;
import org.telegram.telegrambots.meta.api.objects.Update;
import org.telegram.telegrambots.updatesreceivers.DefaultBotSession;

@Service
@Slf4j
public class TelegramBotService extends TelegramLongPollingBot {

    @Value("${app.telegram.bot-token:}")
    private String botToken;

    @Value("${app.telegram.bot-username:CS2PanelBot}")
    private String botUsername;

    @Value("${app.telegram.enabled:false}")
    private boolean enabled;

    @PostConstruct
    public void init() {
        if (!enabled || botToken == null || botToken.isEmpty()) {
            log.info("Telegram bot disabled");
            return;
        }

        try {
            TelegramBotsApi botsApi = new TelegramBotsApi(DefaultBotSession.class);
            botsApi.registerBot(this);
            log.info("Telegram bot started");
        } catch (Exception e) {
            log.error("Failed to start Telegram bot", e);
        }
    }

    @Override
    public void onUpdateReceived(Update update) {
        if (update.hasMessage() && update.getMessage().hasText()) {
            String messageText = update.getMessage().getText();
            Long chatId = update.getMessage().getChatId();

            if (messageText.startsWith("/")) {
                handleCommand(chatId, messageText);
            }
        }
    }

    private void handleCommand(Long chatId, String command) {
        log.info("Telegram command received: {}", command);
        sendMessage(chatId, "Command received: " + command);
    }

    public void sendMessage(Long chatId, String text) {
        try {
            SendMessage message = new SendMessage();
            message.setChatId(chatId.toString());
            message.setText(text);
            execute(message);
        } catch (Exception e) {
            log.error("Failed to send Telegram message", e);
        }
    }

    @Override
    public String getBotUsername() {
        return botUsername;
    }

    @Override
    public String getBotToken() {
        return botToken;
    }
}
