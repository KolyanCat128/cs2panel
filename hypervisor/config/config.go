package config

import (
	"os"
	"strconv"
)

type Config struct {
	HTTPPort int
	GRPCPort int
	DBPath   string
	LogLevel string
}

func Load() *Config {
	return &Config{
		HTTPPort: getEnvInt("HTTP_PORT", 8080),
		GRPCPort: getEnvInt("GRPC_PORT", 9090),
		DBPath:   getEnv("DB_PATH", "/data/hypervisor.db"),
		LogLevel: getEnv("LOG_LEVEL", "info"),
	}
}

func getEnv(key, defaultValue string) string {
	value := os.Getenv(key)
	if value == "" {
		return defaultValue
	}
	return value
}

func getEnvInt(key string, defaultValue int) int {
	valueStr := os.Getenv(key)
	if valueStr == "" {
		return defaultValue
	}
	value, err := strconv.Atoi(valueStr)
	if err != nil {
		return defaultValue
	}
	return value
}
