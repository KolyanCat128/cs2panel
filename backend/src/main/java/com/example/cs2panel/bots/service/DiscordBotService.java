package com.example.cs2panel.bots.service;

import discord4j.core.DiscordClientBuilder;
import discord4j.core.GatewayDiscordClient;
import discord4j.core.event.domain.message.MessageCreateEvent;
import jakarta.annotation.PostConstruct;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
@Slf4j
public class DiscordBotService {

    @Value("${app.discord.bot-token:}")
    private String botToken;

    @Value("${app.discord.enabled:false}")
    private boolean enabled;

    private GatewayDiscordClient gateway;

    @PostConstruct
    public void init() {
        if (!enabled || botToken == null || botToken.isEmpty()) {
            log.info("Discord bot disabled");
            return;
        }

        try {
            gateway = DiscordClientBuilder.create(botToken)
                    .build()
                    .login()
                    .block();

            gateway.on(MessageCreateEvent.class).subscribe(event -> {
                String content = event.getMessage().getContent();
                if (content.startsWith("!cs2panel")) {
                    handleCommand(event);
                }
            });

            log.info("Discord bot started");
        } catch (Exception e) {
            log.error("Failed to start Discord bot", e);
        }
    }

    private void handleCommand(MessageCreateEvent event) {
        String command = event.getMessage().getContent();
        log.info("Discord command received: {}", command);
        // Implement command handling
        event.getMessage().getChannel().block()
                .createMessage("Command received: " + command).block();
    }

    public void sendNotification(String message) {
        if (gateway != null) {
            log.info("Sending Discord notification: {}", message);
            // Send to configured channel
        }
    }
}
