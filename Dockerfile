FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:8.0 AS build

ARG TARGETPLATFORM

WORKDIR /build

ADD https://github.com/openmediatransport/OMTDiscoveryServer.git ./OMTDiscoveryServer

RUN case "$TARGETPLATFORM" in \
        "linux/amd64") dotnet publish ./OMTDiscoveryServer/OMTDiscoveryServer.sln --os linux -a musl-x64 -c Release --self-contained true -o /build/dist ;; \
        "linux/arm/v7") dotnet publish ./OMTDiscoveryServer/OMTDiscoveryServer.sln --os linux -a musl-arm -c Release --self-contained true -o /build/dist ;; \
        "linux/arm64") dotnet publish ./OMTDiscoveryServer/OMTDiscoveryServer.sln --os linux -a musl-arm64 -c Release --self-contained true -o /build/dist ;; \
        "linux/386") dotnet publish ./OMTDiscoveryServer/OMTDiscoveryServer.sln --os linux -a musl-x86 -c Release --self-contained true -o /build/dist ;; \
    esac

FROM docker.io/busybox:stable

WORKDIR /app

COPY --from=build /build/dist .

RUN chmod +x ./OMTDiscoveryServer

EXPOSE 6399

ENTRYPOINT [ "./OMTDiscoveryServer" ]
