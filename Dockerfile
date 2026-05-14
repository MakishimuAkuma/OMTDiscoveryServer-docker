FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:8.0 AS build

ARG TARGETPLATFORM

WORKDIR /build

ADD https://github.com/openmediatransport/libomtnet.git ./libomtnet
ADD https://github.com/openmediatransport/OMTDiscoveryServer.git ./OMTDiscoveryServer

RUN sed -i 's|<TargetFrameworks>.*<\/TargetFrameworks>|<TargetFrameworks>net8.0<\/TargetFrameworks>|g' ./libomtnet/libomtnet.csproj && \
    sed -i '13,15c\    <ProjectReference Include="..\\libomtnet\\libomtnet.csproj" />' ./OMTDiscoveryServer/OMTDiscoveryServer.csproj

RUN case "$TARGETPLATFORM" in \
        "linux/amd64") dotnet publish ./OMTDiscoveryServer/OMTDiscoveryServer.csproj --os linux -a musl-x64 -c Release -p:PublishSingleFile=true -p:PublishAot=false --self-contained true -o /build/dist ;; \
        "linux/arm/v7") dotnet publish ./OMTDiscoveryServer/OMTDiscoveryServer.csproj --os linux -a musl-arm -c Release -p:PublishSingleFile=true -p:PublishAot=false --self-contained true -o /build/dist ;; \
        "linux/arm64") dotnet publish ./OMTDiscoveryServer/OMTDiscoveryServer.csproj --os linux -a musl-arm64 -c Release -p:PublishSingleFile=true -p:PublishAot=false --self-contained true -o /build/dist ;; \
    esac

FROM docker.io/busybox:stable

WORKDIR /app

COPY --from=build /build/dist/OMTDiscoveryServer .

RUN chmod +x ./OMTDiscoveryServer

EXPOSE 6399

ENTRYPOINT [ "./OMTDiscoveryServer" ]
