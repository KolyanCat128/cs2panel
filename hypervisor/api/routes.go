package api

import (
	"net/http"

	"github.com/cs2panel/hypervisor/vm"
	"github.com/gin-gonic/gin"
)

type VMCreateRequest struct {
	UUID          string `json:"uuid"`
	Name          string `json:"name" binding:"required"`
	CPUCores      int    `json:"cpu_cores" binding:"required,min=1"`
	MemoryMB      int    `json:"memory_mb" binding:"required,min=512"`
	DiskGB        int    `json:"disk_gb" binding:"required,min=10"`
	OSType        string `json:"os_type"`
	CloudInitData string `json:"cloud_init_data"`
}

func SetupRoutes(r *gin.Engine, vmManager *vm.Manager) {
	v1 := r.Group("/v1")
	{
		// Health check
		v1.GET("/health", func(c *gin.Context) {
			c.JSON(http.StatusOK, gin.H{
				"status": "healthy",
				"service": "hypervisor-daemon",
			})
		})

		// Metrics
		v1.GET("/metrics", func(c *gin.Context) {
			metrics := vmManager.GetNodeMetrics()
			c.JSON(http.StatusOK, metrics)
		})

		// Node information
		v1.GET("/nodes", func(c *gin.Context) {
			c.JSON(http.StatusOK, gin.H{
				"hostname":     "node-01",
				"ip_address":   "192.168.1.100",
				"cpu_cores":    16,
				"memory_total": 32768,
				"disk_total":   1000,
				"status":       "ONLINE",
			})
		})

		// VM management
		vms := v1.Group("/vms")
		{
			// List VMs
			vms.GET("", func(c *gin.Context) {
				vmList, err := vmManager.ListVMs()
				if err != nil {
					c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
					return
				}
				c.JSON(http.StatusOK, vmList)
			})

			// Get VM by UUID
			vms.GET("/:uuid", func(c *gin.Context) {
				vmUUID := c.Param("uuid")
				vm, err := vmManager.GetVM(vmUUID)
				if err != nil {
					c.JSON(http.StatusNotFound, gin.H{"error": "VM not found"})
					return
				}
				c.JSON(http.StatusOK, vm)
			})

			// Create VM
			vms.POST("", func(c *gin.Context) {
				var req VMCreateRequest
				if err := c.ShouldBindJSON(&req); err != nil {
					c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
					return
				}

				vm, err := vmManager.CreateVM(req.Name, req.CPUCores, req.MemoryMB, req.DiskGB, req.OSType, req.CloudInitData)
				if err != nil {
					c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
					return
				}

				c.JSON(http.StatusCreated, vm)
			})

			// Start VM
			vms.POST("/:uuid/start", func(c *gin.Context) {
				vmUUID := c.Param("uuid")
				if err := vmManager.StartVM(vmUUID); err != nil {
					c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
					return
				}
				c.JSON(http.StatusOK, gin.H{"message": "VM started"})
			})

			// Stop VM
			vms.POST("/:uuid/stop", func(c *gin.Context) {
				vmUUID := c.Param("uuid")
				if err := vmManager.StopVM(vmUUID); err != nil {
					c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
					return
				}
				c.JSON(http.StatusOK, gin.H{"message": "VM stopped"})
			})

			// Reboot VM
			vms.POST("/:uuid/reboot", func(c *gin.Context) {
				vmUUID := c.Param("uuid")
				if err := vmManager.RebootVM(vmUUID); err != nil {
					c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
					return
				}
				c.JSON(http.StatusOK, gin.H{"message": "VM rebooted"})
			})

			// Delete VM
			vms.DELETE("/:uuid", func(c *gin.Context) {
				vmUUID := c.Param("uuid")
				if err := vmManager.DeleteVM(vmUUID); err != nil {
					c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
					return
				}
				c.JSON(http.StatusOK, gin.H{"message": "VM deleted"})
			})
		}

		// Commands (execute arbitrary commands - admin only)
		v1.POST("/commands", func(c *gin.Context) {
			var req struct {
				Command string   `json:"command" binding:"required"`
				Args    []string `json:"args"`
			}
			if err := c.ShouldBindJSON(&req); err != nil {
				c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
				return
			}

			// This would execute system commands - requires authorization
			c.JSON(http.StatusOK, gin.H{
				"message": "Command execution not implemented in stub",
				"command": req.Command,
			})
		})
	}
}
