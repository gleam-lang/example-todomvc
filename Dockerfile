FROM ghcr.io/gleam-lang/gleam:v1.3.2-erlang-alpine

# Add project code
COPY . /build/

# Compile the Gleam application
RUN apk add gcc build-base \
  && cd /build \
  && gleam export erlang-shipment \
  && mv build/erlang-shipment /app \
  && rm -r /build \
  && apk del gcc build-base \
  && addgroup -S todomvc \
  && adduser -S todomvc -G todomvc \
  && chown -R todomvc /app

# Run the application
USER todomvc
WORKDIR /app
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["run"]
