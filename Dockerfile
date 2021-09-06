FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build
WORKDIR /app
COPY Training/Training.csproj .
RUN dotnet restore Training.csproj
COPY ./Training .
RUN dotnet build Training.csproj -c Release -o /out
FROM mcr.microsoft.com/dotnet/aspnet:5.0 AS runtime
WORKDIR /app
COPY --from=build /out ./
ENTRYPOINT ["dotnet", "Training.dll"]