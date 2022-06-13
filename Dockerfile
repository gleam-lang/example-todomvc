FROM ghcr.io/gleam-lang/gleam:v0.22.0-rc1-erlang-alpine

# Create a group and user to run as
RUN addgroup -S todomvc && adduser -S todomvc -G todomvc
USER todomvc

# Add project code
WORKDIR /app/
COPY . ./

# Compile the Gleam application
RUN gleam build

# Run the application
CMD ["gleam", "run"]
