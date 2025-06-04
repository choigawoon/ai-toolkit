#!/bin/bash

# ComfyUI 모델 동기화 스크립트
# 사용법: 
#   ./sync.sh --push [--host 사용자명@원격IP] [--port 포트번호] : 로컬에서 원격 서버로 모델 폴더 전송
#   ./sync.sh --pull [--host 사용자명@원격IP] [--port 포트번호] : 원격 서버에서 로컬로 모델 폴더 가져오기

# 기본 설정 변수
REMOTE_HOST=""
REMOTE_PORT=""
REMOTE_PATH="~/Desktop/ComfyUI/"
LOCAL_PATH="models"
ACTION=""

# 도움말 함수
show_help() {
  echo "사용법: $0 [옵션]"
  echo "옵션:"
  echo "  --push                    로컬에서 원격 서버로 모델 폴더 전송"
  echo "  --pull                    원격 서버에서 로컬로 모델 폴더 가져오기"
  echo "  --host 사용자명@원격IP     원격 호스트 정보 (예: user@192.168.1.100)"
  echo "  --port 포트번호            SSH 포트 번호 (기본값: 22)"
  echo "  --help                    도움말 표시"
  exit 0
}

# 인자 확인
if [ $# -eq 0 ]; then
  show_help
fi

# 인자 파싱
while [ $# -gt 0 ]; do
  case "$1" in
    --push)
      ACTION="push"
      shift
      ;;
    --pull)
      ACTION="pull"
      shift
      ;;
    --host)
      REMOTE_HOST="$2"
      shift 2
      ;;
    --port)
      REMOTE_PORT="$2"
      shift 2
      ;;
    --help)
      show_help
      ;;
    *)
      echo "알 수 없는 옵션: $1"
      show_help
      ;;
  esac
done

# 호스트 정보가 없으면 입력 요청
if [ -z "$REMOTE_HOST" ]; then
  read -p "원격 호스트 정보를 입력하세요 (예: user@192.168.1.100): " REMOTE_HOST
  if [ -z "$REMOTE_HOST" ]; then
    echo "오류: 원격 호스트 정보가 필요합니다."
    exit 1
  fi
fi

# 포트 정보가 없으면 입력 요청
if [ -z "$REMOTE_PORT" ]; then
  read -p "SSH 포트 번호를 입력하세요 (기본값: 22): " REMOTE_PORT
  if [ -z "$REMOTE_PORT" ]; then
    REMOTE_PORT="22"
  fi
fi

# 명령어 처리
case "$ACTION" in
  push)
    echo "로컬에서 원격 서버로 모델 폴더 전송 중..."
    echo "호스트: $REMOTE_HOST, 포트: $REMOTE_PORT"
    rsync -avh --progress -e "ssh -p $REMOTE_PORT" $LOCAL_PATH $REMOTE_HOST:$REMOTE_PATH
    echo "전송 완료!"
    ;;
  pull)
    echo "원격 서버에서 로컬로 모델 폴더 가져오는 중..."
    echo "호스트: $REMOTE_HOST, 포트: $REMOTE_PORT"
    rsync -avh --progress -e "ssh -p $REMOTE_PORT" $REMOTE_HOST:$REMOTE_PATH$LOCAL_PATH .
    echo "가져오기 완료!"
    ;;
  *)
    echo "오류: --push 또는 --pull 옵션을 지정해야 합니다."
    show_help
    ;;
esac
