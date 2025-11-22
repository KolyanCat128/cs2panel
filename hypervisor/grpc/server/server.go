package server

import (
	"context"

	"github.com/cs2panel/hypervisor/grpc/pb"
	"github.com/cs2panel/hypervisor/vm"
	log "github.com/sirupsen/logrus"
	"google.golang.org/grpc"
)

type HypervisorServer struct {
	pb.UnimplementedHypervisorServiceServer
	vmManager *vm.Manager
}

func RegisterServices(s *grpc.Server, vmManager *vm.Manager) {
	pb.RegisterHypervisorServiceServer(s, &HypervisorServer{vmManager: vmManager})
}

func (s *HypervisorServer) CreateVM(ctx context.Context, req *pb.CreateVMRequest) (*pb.VMResponse, error) {
	log.Infof("gRPC CreateVM: %s", req.Name)

	vm, err := s.vmManager.CreateVM(req.Name, int(req.CpuCores), int(req.MemoryMb), int(req.DiskGb), req.OsType, req.CloudInitData)
	if err != nil {
		return nil, err
	}

	return &pb.VMResponse{
		Uuid:     vm.UUID,
		Name:     vm.Name,
		Status:   vm.Status,
		CpuCores: int32(vm.CPUCores),
		MemoryMb: int32(vm.MemoryMB),
		DiskGb:   int32(vm.DiskGB),
	}, nil
}

func (s *HypervisorServer) StartVM(ctx context.Context, req *pb.VMActionRequest) (*pb.VMResponse, error) {
	log.Infof("gRPC StartVM: %s", req.Uuid)

	if err := s.vmManager.StartVM(req.Uuid); err != nil {
		return nil, err
	}

	vm, _ := s.vmManager.GetVM(req.Uuid)

	return &pb.VMResponse{
		Uuid:     vm.UUID,
		Name:     vm.Name,
		Status:   vm.Status,
		CpuCores: int32(vm.CPUCores),
		MemoryMb: int32(vm.MemoryMB),
		DiskGb:   int32(vm.DiskGB),
	}, nil
}

func (s *HypervisorServer) StopVM(ctx context.Context, req *pb.VMActionRequest) (*pb.VMResponse, error) {
	log.Infof("gRPC StopVM: %s", req.Uuid)

	if err := s.vmManager.StopVM(req.Uuid); err != nil {
		return nil, err
	}

	vm, _ := s.vmManager.GetVM(req.Uuid)

	return &pb.VMResponse{
		Uuid:     vm.UUID,
		Name:     vm.Name,
		Status:   vm.Status,
		CpuCores: int32(vm.CPUCores),
		MemoryMb: int32(vm.MemoryMB),
		DiskGb:   int32(vm.DiskGB),
	}, nil
}

func (s *HypervisorServer) ListVMs(ctx context.Context, req *pb.ListVMsRequest) (*pb.ListVMsResponse, error) {
	log.Info("gRPC ListVMs")

	vms, err := s.vmManager.ListVMs()
	if err != nil {
		return nil, err
	}

	var pbVMs []*pb.VMResponse
	for _, vm := range vms {
		pbVMs = append(pbVMs, &pb.VMResponse{
			Uuid:     vm.UUID,
			Name:     vm.Name,
			Status:   vm.Status,
			CpuCores: int32(vm.CPUCores),
			MemoryMb: int32(vm.MemoryMB),
			DiskGb:   int32(vm.DiskGB),
		})
	}

	return &pb.ListVMsResponse{Vms: pbVMs}, nil
}
