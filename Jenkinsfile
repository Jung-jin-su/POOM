pipeline{
  agent any
  stages{
    stage('백엔드 자동 배포') {
      stages {
        stage('gradlew 권한'){
          steps{
            dir('backend'){
              sh "chmod +x gradlew"
            }
          }
        }
        stage('gradle 빌드'){
          steps{
            dir('backend'){
              sh './gradlew clean build --refresh-dependencies'
            }
          }
        }
        stage('백엔드 이미지 생성'){
          steps{
            dir('backend'){
              sh "./gradlew bootBuildImage"
            }
          }
        }
        stage('백엔드 컨테이너 삭제'){
          steps{
            catchError{
              sh "docker rm --force backend"
            }
          }
        }
        stage('백엔드 컨테이너 생성') {
          steps {
            sh "docker run -d -p 8080:8080 -v /etc/localtime:/etc/localtime:ro -e TZ=Asia/Seoul -e LC_ALL=C.UTF-8 --name backend backend:0.0.1-SNAPSHOT"
          }
        }
      }
    }
  }
}
