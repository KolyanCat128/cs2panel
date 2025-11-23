package com.example.cs2panel.k8s.service;

import io.fabric8.kubernetes.api.model.Namespace;
import io.fabric8.kubernetes.api.model.Pod;
import io.fabric8.kubernetes.client.Config;
import io.fabric8.kubernetes.client.ConfigBuilder;
import io.fabric8.kubernetes.client.KubernetesClient;
import io.fabric8.kubernetes.client.KubernetesClientBuilder;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@Slf4j
public class KubernetesService {

    @Value("${app.kubernetes.enabled:false}")
    private boolean enabled;

    @Value("${app.kubernetes.kubeconfig-path:~/.kube/config}")
    private String kubeconfigPath;

    @Value("${app.kubernetes.namespace:cs2-servers}")
    private String namespace;

    private KubernetesClient client;

    public void init() {
        if (!enabled) {
            log.info("Kubernetes integration disabled");
            return;
        }

        try {
            Config config = Config.autoConfigure(kubeconfigPath);
            client = new KubernetesClientBuilder().withConfig(config).build();
            log.info("Kubernetes client initialized");
        } catch (Exception e) {
            log.error("Failed to initialize Kubernetes client", e);
        }
    }

    public List<Pod> listPods() {
        if (client == null) return List.of();
        return client.pods().inNamespace(namespace).list().getItems();
    }

    public void createCS2ServerResource(String serverName, int replicas) {
        if (client == null) {
            log.warn("Kubernetes client not initialized");
            return;
        }

        log.info("Creating CS2Server resource: {} with {} replicas", serverName, replicas);
        // Create custom resource instance
    }

    public void deleteCS2ServerResource(String serverName) {
        if (client == null) return;
        log.info("Deleting CS2Server resource: {}", serverName);
    }

    public void ensureNamespace() {
        if (client == null) return;

        Namespace ns = client.namespaces().withName(namespace).get();
        if (ns == null) {
            Namespace newNs = new io.fabric8.kubernetes.api.model.NamespaceBuilder()
                    .withNewMetadata().withName(namespace).endMetadata()
                    .build();
            client.namespaces().resource(newNs).create();
            log.info("Created namespace: {}", namespace);
        }
    }
}
