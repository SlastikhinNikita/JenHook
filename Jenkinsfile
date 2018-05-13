node {
  checkout scm
  def customImage = docker.build("registry.domain.tld/image:${env.BUILD_ID}")
/*
  customImage.inside {
    sh 'make test'
  }
*/
  customImage.push()
  customImage.push('latest')
}


