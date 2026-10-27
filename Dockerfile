FROM swipl:stable
WORKDIR /app
COPY . .
ENV PORT=8080
EXPOSE 8080
CMD ["swipl", "server.pl"]
