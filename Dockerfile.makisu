FROM gcr.io/makisu-project/makisu:latest AS makisu

FROM lnl7/nix:latest as nix
COPY --from=makisu /makisu-internal /makisu-internal

ENTRYPOINT ["/makisu-internal/makisu"]
