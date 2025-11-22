.PHONY: build run test proto clean

build:
	go build -o bin/hypervisor-daemon .

run:
	go run main.go

test:
	go test -v ./...

proto:
	protoc --go_out=. --go_opt=paths=source_relative \
		--go-grpc_out=. --go-grpc_opt=paths=source_relative \
		grpc/pb/hypervisor.proto

docker-build:
	docker build -t cs2panel/hypervisor:latest .

clean:
	rm -rf bin/
	rm -f hypervisor.db
