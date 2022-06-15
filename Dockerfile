FROM ghcr.io/gleam-lang/gleam:v0.22.0-rc1-erlang-alpine

# Add project code
COPY . /build/

# Compile the Gleam application
RUN cd /build \
  && gleam export erlang-shipment \
  && mv build/erlang-shipment/* /app \
  && rm -r /build \
  && addgroup -S todomvc \
  && adduser -S todomvc -G todomvc \
  && chown -R todomvc /app

# Run the application
USER todomvc
WORKDIR /app
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["run"]
