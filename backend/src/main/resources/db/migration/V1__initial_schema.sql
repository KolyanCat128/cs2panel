-- Initial Database Schema for CS2 Infrastructure Panel

-- Organizations
CREATE TABLE organizations (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(200) UNIQUE NOT NULL,
    slug VARCHAR(100),
    description TEXT,
    website VARCHAR(255),
    billing_email VARCHAR(255),
    support_email VARCHAR(255),
    phone VARCHAR(20),
    address TEXT,
    tax_id VARCHAR(100),
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- Permissions
CREATE TABLE permissions (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    description VARCHAR(255),
    category VARCHAR(50)
);

-- Roles
CREATE TABLE roles (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description VARCHAR(255)
);

-- Role Permissions
CREATE TABLE role_permissions (
    role_id BIGINT REFERENCES roles(id) ON DELETE CASCADE,
    permission_id BIGINT REFERENCES permissions(id) ON DELETE CASCADE,
    PRIMARY KEY (role_id, permission_id)
);

-- Users
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone VARCHAR(20),
    avatar_url VARCHAR(500),
    two_fa_enabled BOOLEAN DEFAULT FALSE,
    two_fa_secret VARCHAR(255),
    enabled BOOLEAN NOT NULL DEFAULT TRUE,
    email_verified BOOLEAN DEFAULT FALSE,
    account_locked BOOLEAN DEFAULT FALSE,
    failed_login_attempts INTEGER DEFAULT 0,
    last_login_at TIMESTAMP,
    last_login_ip VARCHAR(45),
    organization_id BIGINT REFERENCES organizations(id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    deleted_at TIMESTAMP,
    notes TEXT
);

CREATE INDEX idx_user_email ON users(email);
CREATE INDEX idx_user_username ON users(username);

-- User Roles
CREATE TABLE user_roles (
    user_id BIGINT REFERENCES users(id) ON DELETE CASCADE,
    role_id BIGINT REFERENCES roles(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, role_id)
);

-- Refresh Tokens
CREATE TABLE refresh_tokens (
    id BIGSERIAL PRIMARY KEY,
    token VARCHAR(500) UNIQUE NOT NULL,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP NOT NULL,
    revoked BOOLEAN DEFAULT FALSE,
    ip_address VARCHAR(45),
    user_agent VARCHAR(500)
);

CREATE INDEX idx_token ON refresh_tokens(token);

-- Hypervisor Nodes
CREATE TABLE hypervisor_nodes (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    hostname VARCHAR(255) UNIQUE NOT NULL,
    ip_address VARCHAR(45) NOT NULL,
    port INTEGER DEFAULT 8080,
    status VARCHAR(50) DEFAULT 'OFFLINE',
    cpu_cores INTEGER,
    cpu_used INTEGER DEFAULT 0,
    memory_total_mb BIGINT,
    memory_used_mb BIGINT DEFAULT 0,
    disk_total_gb BIGINT,
    disk_used_gb BIGINT DEFAULT 0,
    location VARCHAR(100),
    datacenter VARCHAR(100),
    enabled BOOLEAN DEFAULT TRUE,
    last_heartbeat TIMESTAMP,
    metadata JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- Virtual Machines
CREATE TABLE virtual_machines (
    id BIGSERIAL PRIMARY KEY,
    uuid UUID UNIQUE NOT NULL,
    name VARCHAR(200) NOT NULL,
    node_id BIGINT REFERENCES hypervisor_nodes(id),
    owner_id BIGINT REFERENCES users(id),
    status VARCHAR(50) DEFAULT 'STOPPED',
    cpu_cores INTEGER NOT NULL,
    memory_mb INTEGER NOT NULL,
    disk_gb INTEGER NOT NULL,
    os_type VARCHAR(50),
    os_version VARCHAR(100),
    ip_address VARCHAR(45),
    vnc_port INTEGER,
    vnc_password VARCHAR(100),
    cloud_init_enabled BOOLEAN DEFAULT FALSE,
    cloud_init_data TEXT,
    auto_start BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE INDEX idx_vm_node ON virtual_machines(node_id);
CREATE INDEX idx_vm_owner ON virtual_machines(owner_id);

-- VM Snapshots
CREATE TABLE vm_snapshots (
    id BIGSERIAL PRIMARY KEY,
    vm_id BIGINT REFERENCES virtual_machines(id) ON DELETE CASCADE,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    size_mb BIGINT,
    created_by BIGINT REFERENCES users(id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Storage Pools
CREATE TABLE storage_pools (
    id BIGSERIAL PRIMARY KEY,
    node_id BIGINT REFERENCES hypervisor_nodes(id),
    name VARCHAR(200) NOT NULL,
    type VARCHAR(50),
    path VARCHAR(500),
    total_gb BIGINT,
    used_gb BIGINT DEFAULT 0,
    enabled BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Network Pools
CREATE TABLE network_pools (
    id BIGSERIAL PRIMARY KEY,
    node_id BIGINT REFERENCES hypervisor_nodes(id),
    name VARCHAR(200) NOT NULL,
    bridge_name VARCHAR(100),
    vlan_id INTEGER,
    subnet VARCHAR(50),
    gateway VARCHAR(45),
    dns_servers VARCHAR(255),
    enabled BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Firewall Rules
CREATE TABLE firewall_rules (
    id BIGSERIAL PRIMARY KEY,
    node_id BIGINT REFERENCES hypervisor_nodes(id),
    name VARCHAR(200) NOT NULL,
    action VARCHAR(20) NOT NULL,
    protocol VARCHAR(20),
    source_ip VARCHAR(50),
    source_port VARCHAR(50),
    destination_ip VARCHAR(50),
    destination_port VARCHAR(50),
    direction VARCHAR(20),
    zone VARCHAR(50),
    priority INTEGER DEFAULT 100,
    enabled BOOLEAN DEFAULT TRUE,
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- VPN Configurations
CREATE TABLE vpn_configs (
    id BIGSERIAL PRIMARY KEY,
    node_id BIGINT REFERENCES hypervisor_nodes(id),
    name VARCHAR(200) NOT NULL,
    type VARCHAR(50) NOT NULL,
    config_data TEXT,
    status VARCHAR(50) DEFAULT 'STOPPED',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- Billing Plans
CREATE TABLE billing_plans (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    plan_type VARCHAR(50),
    billing_cycle VARCHAR(50),
    price DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    cpu_cores INTEGER,
    memory_mb INTEGER,
    disk_gb INTEGER,
    bandwidth_gb INTEGER,
    game_slots INTEGER,
    features JSONB,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- Subscriptions
CREATE TABLE subscriptions (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id),
    plan_id BIGINT REFERENCES billing_plans(id),
    status VARCHAR(50) DEFAULT 'ACTIVE',
    start_date DATE NOT NULL,
    end_date DATE,
    auto_renew BOOLEAN DEFAULT TRUE,
    trial_end_date DATE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    cancelled_at TIMESTAMP
);

-- Invoices
CREATE TABLE invoices (
    id BIGSERIAL PRIMARY KEY,
    invoice_number VARCHAR(100) UNIQUE NOT NULL,
    user_id BIGINT REFERENCES users(id),
    subscription_id BIGINT REFERENCES subscriptions(id),
    status VARCHAR(50) DEFAULT 'PENDING',
    subtotal DECIMAL(10, 2) NOT NULL,
    tax DECIMAL(10, 2) DEFAULT 0,
    total DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    due_date DATE NOT NULL,
    paid_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_invoice_user ON invoices(user_id);
CREATE INDEX idx_invoice_number ON invoices(invoice_number);

-- Invoice Items
CREATE TABLE invoice_items (
    id BIGSERIAL PRIMARY KEY,
    invoice_id BIGINT REFERENCES invoices(id) ON DELETE CASCADE,
    description VARCHAR(500) NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price DECIMAL(10, 2) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL
);

-- Payments
CREATE TABLE payments (
    id BIGSERIAL PRIMARY KEY,
    invoice_id BIGINT REFERENCES invoices(id),
    user_id BIGINT REFERENCES users(id),
    amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    payment_method VARCHAR(50),
    transaction_id VARCHAR(255),
    status VARCHAR(50) DEFAULT 'PENDING',
    metadata JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- CS2 Servers
CREATE TABLE cs2_servers (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    owner_id BIGINT REFERENCES users(id),
    node_id BIGINT REFERENCES hypervisor_nodes(id),
    vm_id BIGINT REFERENCES virtual_machines(id),
    status VARCHAR(50) DEFAULT 'STOPPED',
    ip_address VARCHAR(45),
    port INTEGER DEFAULT 27015,
    rcon_password VARCHAR(100),
    server_password VARCHAR(100),
    max_players INTEGER DEFAULT 32,
    tickrate INTEGER DEFAULT 128,
    map VARCHAR(100) DEFAULT 'de_dust2',
    game_mode VARCHAR(50),
    steamcmd_path VARCHAR(500),
    install_path VARCHAR(500),
    version VARCHAR(50),
    auto_update BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE INDEX idx_cs2_owner ON cs2_servers(owner_id);

-- CS2 Plugins
CREATE TABLE cs2_plugins (
    id BIGSERIAL PRIMARY KEY,
    server_id BIGINT REFERENCES cs2_servers(id) ON DELETE CASCADE,
    name VARCHAR(200) NOT NULL,
    version VARCHAR(50),
    enabled BOOLEAN DEFAULT TRUE,
    config_data TEXT,
    file_path VARCHAR(500),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- AI Scenarios
CREATE TABLE ai_scenarios (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    created_by BIGINT REFERENCES users(id),
    scenario_data JSONB NOT NULL,
    status VARCHAR(50) DEFAULT 'DRAFT',
    version INTEGER DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- AI Jobs
CREATE TABLE ai_jobs (
    id BIGSERIAL PRIMARY KEY,
    scenario_id BIGINT REFERENCES ai_scenarios(id),
    status VARCHAR(50) DEFAULT 'PENDING',
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    result_data JSONB,
    artifact_url VARCHAR(500),
    error_message TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Monitoring Metrics
CREATE TABLE monitoring_metrics (
    id BIGSERIAL PRIMARY KEY,
    resource_type VARCHAR(50) NOT NULL,
    resource_id BIGINT NOT NULL,
    metric_name VARCHAR(100) NOT NULL,
    metric_value DOUBLE PRECISION NOT NULL,
    unit VARCHAR(50),
    tags JSONB,
    timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_metrics_resource ON monitoring_metrics(resource_type, resource_id);
CREATE INDEX idx_metrics_timestamp ON monitoring_metrics(timestamp);

-- Alert Rules
CREATE TABLE alert_rules (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    resource_type VARCHAR(50),
    metric_name VARCHAR(100) NOT NULL,
    condition VARCHAR(50) NOT NULL,
    threshold DOUBLE PRECISION NOT NULL,
    duration_seconds INTEGER,
    severity VARCHAR(50) DEFAULT 'WARNING',
    enabled BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- Alerts
CREATE TABLE alerts (
    id BIGSERIAL PRIMARY KEY,
    rule_id BIGINT REFERENCES alert_rules(id),
    resource_type VARCHAR(50),
    resource_id BIGINT,
    severity VARCHAR(50),
    message TEXT NOT NULL,
    status VARCHAR(50) DEFAULT 'ACTIVE',
    triggered_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP,
    acknowledged_at TIMESTAMP,
    acknowledged_by BIGINT REFERENCES users(id)
);

-- Kubernetes Clusters
CREATE TABLE k8s_clusters (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    kubeconfig TEXT NOT NULL,
    api_server VARCHAR(500) NOT NULL,
    namespace VARCHAR(100) DEFAULT 'default',
    enabled BOOLEAN DEFAULT TRUE,
    last_sync TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- Insert default roles
INSERT INTO roles (name, description) VALUES
('ROLE_ADMIN', 'Administrator with full access'),
('ROLE_OPERATOR', 'Infrastructure operator'),
('ROLE_BILLING', 'Billing management'),
('ROLE_SUPPORT', 'Support staff'),
('ROLE_USER', 'Regular user');

-- Insert default permissions
INSERT INTO permissions (name, description, category) VALUES
('VM_CREATE', 'Create virtual machines', 'VM'),
('VM_READ', 'View virtual machines', 'VM'),
('VM_UPDATE', 'Update virtual machines', 'VM'),
('VM_DELETE', 'Delete virtual machines', 'VM'),
('VM_START', 'Start virtual machines', 'VM'),
('VM_STOP', 'Stop virtual machines', 'VM'),
('FIREWALL_CREATE', 'Create firewall rules', 'FIREWALL'),
('FIREWALL_READ', 'View firewall rules', 'FIREWALL'),
('FIREWALL_UPDATE', 'Update firewall rules', 'FIREWALL'),
('FIREWALL_DELETE', 'Delete firewall rules', 'FIREWALL'),
('BILLING_READ', 'View billing information', 'BILLING'),
('BILLING_CREATE', 'Create invoices', 'BILLING'),
('BILLING_REFUND', 'Process refunds', 'BILLING'),
('USER_CREATE', 'Create users', 'USER'),
('USER_READ', 'View users', 'USER'),
('USER_UPDATE', 'Update users', 'USER'),
('USER_DELETE', 'Delete users', 'USER'),
('CS2_CREATE', 'Create CS2 servers', 'CS2'),
('CS2_READ', 'View CS2 servers', 'CS2'),
('CS2_UPDATE', 'Update CS2 servers', 'CS2'),
('CS2_DELETE', 'Delete CS2 servers', 'CS2'),
('AI_SCENARIO_CREATE', 'Create AI scenarios', 'AI'),
('AI_SCENARIO_EXECUTE', 'Execute AI scenarios', 'AI'),
('NODE_CREATE', 'Create hypervisor nodes', 'NODE'),
('NODE_READ', 'View hypervisor nodes', 'NODE'),
('NODE_UPDATE', 'Update hypervisor nodes', 'NODE'),
('NODE_DELETE', 'Delete hypervisor nodes', 'NODE');

-- Assign all permissions to ROLE_ADMIN for simplicity
-- In a real application, you would be more granular
INSERT INTO role_permissions (role_id, permission_id)
SELECT
    (SELECT id FROM roles WHERE name = 'ROLE_ADMIN'),
    p.id
FROM
    permissions p;
