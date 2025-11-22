package main

import (
	"context"
	"fmt"
	"net"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/cs2panel/hypervisor/api"
	"github.com/cs2panel/hypervisor/config"
	"github.com/cs2panel/hypervisor/db"
	"github.com/cs2panel/hypervisor/grpc/server"
	"github.com/cs2panel/hypervisor/vm"
	"github.com/gin-gonic/gin"
	log "github.com/sirupsen/logrus"
	"google.golang.org/grpc"
)

func main() {
	// Load configuration
	cfg := config.Load()

	// Setup logging
	log.SetFormatter(&log.JSONFormatter{})
	log.SetLevel(log.InfoLevel)
	if cfg.LogLevel == "debug" {
		log.SetLevel(log.DebugLevel)
	}

	log.Info("Starting CS2Panel Hypervisor Daemon")

	// Initialize database
	database, err := db.Initialize(cfg.DBPath)
	if err != nil {
		log.Fatalf("Failed to initialize database: %v", err)
	}

	// Initialize VM manager
	vmManager := vm.NewManager(database)

	// Start HTTP API server
	router := gin.Default()
	api.SetupRoutes(router, vmManager)

	httpServer := &http.Server{
		Addr:    fmt.Sprintf(":%d", cfg.HTTPPort),
		Handler: router,
	}

	go func() {
		log.Infof("HTTP API listening on :%d", cfg.HTTPPort)
		if err := httpServer.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("HTTP server error: %v", err)
		}
	}()

	// Start gRPC server
	grpcServer := grpc.NewServer()
	server.RegisterServices(grpcServer, vmManager)

	grpcListener, err := net.Listen("tcp", fmt.Sprintf(":%d", cfg.GRPCPort))
	if err != nil {
		log.Fatalf("Failed to listen for gRPC: %v", err)
	}

	go func() {
		log.Infof("gRPC server listening on :%d", cfg.GRPCPort)
		if err := grpcServer.Serve(grpcListener); err != nil {
			log.Fatalf("gRPC server error: %v", err)
		}
	}()

	// Wait for interrupt signal
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	log.Info("Shutting down servers...")

	// Graceful shutdown
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := httpServer.Shutdown(ctx); err != nil {
		log.Errorf("HTTP server shutdown error: %v", err)
	}

	grpcServer.GracefulStop()

	log.Info("Servers stopped")
}
