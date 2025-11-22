package vm

import (
	"fmt"
	"os/exec"
	"strconv"

	"github.com/cs2panel/hypervisor/db"
	log "github.com/sirupsen/logrus"
	"gorm.io/gorm"
)

type Manager struct {
	db *gorm.DB
}

func NewManager(database *gorm.DB) *Manager {
	return &Manager{db: database}
}

func (m *Manager) CreateVM(name string, cpuCores, memoryMB, diskGB int, osType string, cloudInitData string) (*db.VirtualMachine, error) {
	vm, err := db.CreateVM(m.db, name, cpuCores, memoryMB, diskGB, osType, cloudInitData)
	if err != nil {
		return nil, err
	}

	// Create disk image (simulated)
	diskPath := fmt.Sprintf("/var/lib/vms/%s.qcow2", vm.UUID)
	log.Infof("Creating disk image: %s (%dGB)", diskPath, diskGB)

	// In production, this would run:
	// qemu-img create -f qcow2 diskPath diskGB
	// For now, we just log it

	return vm, nil
}

func (m *Manager) StartVM(vmUUID string) error {
	vm, err := db.GetVMByUUID(m.db, vmUUID)
	if err != nil {
		return err
	}

	if vm.Status == "RUNNING" {
		return fmt.Errorf("VM already running")
	}

	// Build QEMU command
	args := []string{
		"-name", vm.Name,
		"-cpu", "host",
		"-smp", strconv.Itoa(vm.CPUCores),
		"-m", strconv.Itoa(vm.MemoryMB),
		"-drive", fmt.Sprintf("file=/var/lib/vms/%s.qcow2,format=qcow2", vm.UUID),
		"-vnc", fmt.Sprintf(":1"),
		"-daemonize",
	}

	log.Infof("Starting VM: %s (UUID: %s)", vm.Name, vm.UUID)
	log.Debugf("QEMU command: qemu-system-x86_64 %v", args)

	// In production, execute QEMU:
	// cmd := exec.Command("qemu-system-x86_64", args...)
	// if err := cmd.Start(); err != nil {
	//     return err
	// }

	// Simulate successful start
	db.UpdateVMStatus(m.db, vmUUID, "RUNNING")

	log.Infof("VM started successfully: %s", vm.Name)
	return nil
}

func (m *Manager) StopVM(vmUUID string) error {
	vm, err := db.GetVMByUUID(m.db, vmUUID)
	if err != nil {
		return err
	}

	if vm.Status != "RUNNING" {
		return fmt.Errorf("VM not running")
	}

	log.Infof("Stopping VM: %s (UUID: %s)", vm.Name, vm.UUID)

	// In production, send shutdown signal to QEMU process
	// kill -SIGTERM vm.PID

	db.UpdateVMStatus(m.db, vmUUID, "STOPPED")

	log.Infof("VM stopped successfully: %s", vm.Name)
	return nil
}

func (m *Manager) RebootVM(vmUUID string) error {
	if err := m.StopVM(vmUUID); err != nil {
		return err
	}
	return m.StartVM(vmUUID)
}

func (m *Manager) DeleteVM(vmUUID string) error {
	vm, err := db.GetVMByUUID(m.db, vmUUID)
	if err != nil {
		return err
	}

	if vm.Status == "RUNNING" {
		if err := m.StopVM(vmUUID); err != nil {
			return err
		}
	}

	// Delete disk image
	diskPath := fmt.Sprintf("/var/lib/vms/%s.qcow2", vm.UUID)
	log.Infof("Deleting disk image: %s", diskPath)

	// In production:
	// os.Remove(diskPath)

	return db.DeleteVM(m.db, vmUUID)
}

func (m *Manager) GetVM(vmUUID string) (*db.VirtualMachine, error) {
	return db.GetVMByUUID(m.db, vmUUID)
}

func (m *Manager) ListVMs() ([]db.VirtualMachine, error) {
	return db.ListVMs(m.db)
}

func (m *Manager) GetNodeMetrics() map[string]interface{} {
	// In production, fetch real metrics from system
	return map[string]interface{}{
		"cpu_usage":    45.2,
		"memory_total": 32768,
		"memory_used":  16384,
		"disk_total":   1000,
		"disk_used":    450,
	}
}
