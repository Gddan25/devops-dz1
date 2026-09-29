FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ARG VERSION=dev
RUN echo "${VERSION}" > /app/VERSION

ENV APP_PORT=5003
ENV PYTHONDONTWRITEBYTECODE=1
ENV MARKER=boxlab

EXPOSE 5003

CMD ["python", "app.py"]
