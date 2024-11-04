# syntax=docker/dockerfile:1.7.0

ARG PYTHON_VERSION=3.11.2

FROM python:${PYTHON_VERSION}-slim as builder

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get -qq update && apt-get -qq install \
    --no-install-recommends -y \
    curl \
    gcc \
    libpq-dev \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

ENV PIP_NO_CACHE_DIR=off
ENV PIP_DISABLE_PIP_VERSION_CHECK=on
ENV PIP_DEFAULT_TIMEOUT=100

ENV POETRY_HOME="/opt/poetry"
ENV POETRY_VERSION=1.8.4
ENV POETRY_VIRTUALENVS_IN_PROJECT=true
ENV POETRY_NO_INTERACTION=1

ENV VENV="/opt/venv"
ENV PATH="$POETRY_HOME/bin:$VENV/bin:$PATH"

WORKDIR /

COPY requirements.txt .

RUN python -m venv $VENV --copies \
    && . "${VENV}/bin/activate" \
    && python -m pip install "poetry==${POETRY_VERSION}" \
    && python -m pip install -r requirements.txt

FROM public.ecr.aws/spacelift/runner-pulumi-python:v3.137.0 as runner

ARG HOME="/home/spacelift"
ARG VENV="/opt/venv"
ENV PATH="${VENV}/bin:${HOME}/.local/bin:$PATH"

COPY --from=builder $VENV $VENV

CMD ["sleep", "infinity"]

LABEL org.opencontainers.image.title="runner-pulumi-python"
