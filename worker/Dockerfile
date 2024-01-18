ARG BUILDPLATFORM
ARG TARGETPLATFORM
ARG TARGETARCH

FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:7.0 as build
RUN echo "I am running on $BUILDPLATFORM, building for $TARGETPLATFORM"

WORKDIR /source
COPY *.csproj .
RUN dotnet restore -a $TARGETARCH

COPY . .

#stage1: build and run the unit tests 
RUN dotnet test --no-build --verbosity normal
RUN dotnet publish -c release -o /app -a $TARGETARCH --self-contained false --no-restore

#stage2: build the production image
FROM mcr.microsoft.com/dotnet/runtime:7.0
WORKDIR /app
COPY --from=build /app .
ENTRYPOINT ["dotnet", "Worker.dll"]
