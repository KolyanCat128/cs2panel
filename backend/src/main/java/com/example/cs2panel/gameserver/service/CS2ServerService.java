package com.example.cs2panel.gameserver.service;

import com.example.cs2panel.gameserver.entity.CS2Server;
import com.example.cs2panel.gameserver.repository.CS2ServerRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class CS2ServerService {

    private final CS2ServerRepository serverRepository;

    @Value("${app.cs2.steamcmd-path:/opt/steamcmd}")
    private String steamcmdPath;

    @Value("${app.cs2.servers-base-path:/opt/cs2-servers}")
    private String serversBasePath;

    @Transactional
    public CS2Server createServer(CS2Server server) {
        server.setSteamcmdPath(steamcmdPath);
        server.setInstallPath(serversBasePath + "/" + server.getName());
        server.setStatus("STOPPED");

        server = serverRepository.save(server);

        // Call deployment script or ansible playbook
        deploySteamCmd(server);

        log.info("CS2 server created: {}", server.getName());
        return server;
    }

    public CS2Server getServer(Long id) {
        return serverRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("CS2 server not found"));
    }

    public List<CS2Server> getAllServers() {
        return serverRepository.findAll();
    }

    public List<CS2Server> getUserServers(Long userId) {
        return serverRepository.findByOwnerId(userId);
    }

    @Transactional
    public void startServer(Long id) {
        CS2Server server = getServer(id);
        server.setStatus("STARTING");
        serverRepository.save(server);

        // Execute start command via SSH or systemd
        executeServerCommand(server, "start");

        server.setStatus("RUNNING");
        serverRepository.save(server);
        log.info("CS2 server started: {}", server.getName());
    }

    @Transactional
    public void stopServer(Long id) {
        CS2Server server = getServer(id);
        server.setStatus("STOPPING");
        serverRepository.save(server);

        executeServerCommand(server, "stop");

        server.setStatus("STOPPED");
        serverRepository.save(server);
        log.info("CS2 server stopped: {}", server.getName());
    }

    @Transactional
    public void updateServer(Long id) {
        CS2Server server = getServer(id);
        log.info("Updating CS2 server: {}", server.getName());

        // Run SteamCMD update
        executeSteamCmdUpdate(server);

        log.info("CS2 server updated: {}", server.getName());
    }

    @Transactional
    public void deleteServer(Long id) {
        CS2Server server = getServer(id);
        serverRepository.delete(server);

        // Clean up server files
        cleanupServerFiles(server);

        log.info("CS2 server deleted: {}", server.getName());
    }

    private void deploySteamCmd(CS2Server server) {
        // TODO: Implement SteamCMD deployment
        // This would typically:
        // 1. SSH to the node
        // 2. Run steamcmd +login anonymous +app_update 730 +quit
        // 3. Configure server.cfg
        // 4. Set up systemd service
        log.info("Deploying SteamCMD for server: {}", server.getName());
    }

    private void executeServerCommand(CS2Server server, String command) {
        // TODO: Implement server command execution
        // Use SSH client or systemd control via daemon
        log.info("Executing command '{}' for server: {}", command, server.getName());
    }

    private void executeSteamCmdUpdate(CS2Server server) {
        // TODO: Run steamcmd update
        log.info("Running SteamCMD update for: {}", server.getName());
    }

    private void cleanupServerFiles(CS2Server server) {
        // TODO: Remove server installation directory
        log.info("Cleaning up files for: {}", server.getName());
    }
}
