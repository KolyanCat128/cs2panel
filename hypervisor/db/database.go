package db

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

type VirtualMachine struct {
	ID         uint      `gorm:"primaryKey"`
	UUID       string    `gorm:"uniqueIndex;not null"`
	Name       string    `gorm:"not null"`
	Status     string    `gorm:"default:STOPPED"`
	CPUCores   int       `gorm:"not null"`
	MemoryMB   int       `gorm:"not null"`
	DiskGB     int       `gorm:"not null"`
	OSType     string
	PID        int
	VNCPort    int
	CreatedAt  time.Time
	UpdatedAt  time.Time
}

func Initialize(dbPath string) (*gorm.DB, error) {
	db, err := gorm.Open(sqlite.Open(dbPath), &gorm.Config{})
	if err != nil {
		return nil, err
	}

	// Auto migrate schemas
	if err := db.AutoMigrate(&VirtualMachine{}); err != nil {
		return nil, err
	}

	return db, nil
}

func CreateVM(db *gorm.DB, name string, cpuCores, memoryMB, diskGB int, osType string) (*VirtualMachine, error) {
	vm := &VirtualMachine{
		UUID:     uuid.New().String(),
		Name:     name,
		Status:   "STOPPED",
		CPUCores: cpuCores,
		MemoryMB: memoryMB,
		DiskGB:   diskGB,
		OSType:   osType,
	}

	result := db.Create(vm)
	return vm, result.Error
}

func GetVMByUUID(db *gorm.DB, vmUUID string) (*VirtualMachine, error) {
	var vm VirtualMachine
	result := db.Where("uuid = ?", vmUUID).First(&vm)
	return &vm, result.Error
}

func ListVMs(db *gorm.DB) ([]VirtualMachine, error) {
	var vms []VirtualMachine
	result := db.Find(&vms)
	return vms, result.Error
}

func UpdateVMStatus(db *gorm.DB, vmUUID, status string) error {
	return db.Model(&VirtualMachine{}).Where("uuid = ?", vmUUID).Update("status", status).Error
}

func DeleteVM(db *gorm.DB, vmUUID string) error {
	return db.Where("uuid = ?", vmUUID).Delete(&VirtualMachine{}).Error
}
