FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:8.0 AS build

ARG TARGETARCH

WORKDIR /build

ADD https://github.com/openmediatransport/OMTDiscoveryServer.git ./OMTDiscoveryServer

RUN case "$TARGETPLATFORM" in \
        "linux/amd64") dotnet publish ./OMTDiscoveryServer.sln --os linux -a musl-x64 -c Release -p:PublishSingleFile=true --self-contained true -o /build/dist ;; \
        "linux/arm") dotnet publish ./OMTDiscoveryServer.sln --os linux -a musl-arm -c Release -p:PublishSingleFile=true --self-contained true -o /build/dist ;; \
        "linux/arm64") dotnet publish ./OMTDiscoveryServer.sln --os linux -a musl-arm64 -c Release -p:PublishSingleFile=true --self-contained true -o /build/dist ;; \
        "linux/386") dotnet publish ./OMTDiscoveryServer.sln --os linux -a musl-x86 -c Release -p:PublishSingleFile=true --self-contained true -o /build/dist ;; \
    esac

FROM docker.io/busybox:stable

WORKDIR /app

COPY --from=build /build/dist /app

RUN chmod +x ./OMTDiscoveryServer

EXPOSE 6399

ENTRYPOINT [ "./OMTDiscoveryServer" ]
