#/etc/puppet/modules/buildbot_slave/manifests/buildbot.pp

include apt

# buildbot class for the buildbot slaves.
class buildbot_slave::buildbot (
  $buildbot_packages = [],
  $ant = ['apache-ant-1.8.4', 'apache-ant-1.9.4', 'apache-ant-1.9.7'],
  $maven = ['apache-maven-2.2.1', 'apache-maven-3.0.4', 'apache-maven-3.0.5', 'apache-maven-3.2.1', 'apache-maven-3.2.5', 'apache-maven-3.3.3', 'apache-maven-3.3.9'],
  $java_asfpackages = ['jdk1.5.0_22-64', 'jdk1.6.0_45-64', 'jdk1.7.0_79-unlimited-security', 'jdk1.7.0_80', 'jdk1.8.0_66-unlimited-security', 'jdk1.8.0_92', 'jdk1.8.0_102', 'jdk-9-ea-b132', 'jdk-9-ea-b139', 'jigsaw-jdk-9-ea-b142', 'ibm-java-x86_64-80'],
  $tools = ['ant', 'maven', 'java'],
) {

  require stdlib
  require buildbot_slave

  #define all symlink making iterators
  define buildbot_slave::mkdir_tools ($tool = $title) {
    file {"/home/buildslave/slave/tools/${tool}":
      ensure => directory,
      owner  => 'buildslave',
      group  => 'buildslave',
    }
  }

  #define ant symlinking
  define build_slaves::symlink_ant ($ant_version = $title) {
    file {"/home/buildslave/slave/tools/ant/${ant_version}":
      ensure => link,
      target => "/usr/local/asfpackages/ant/${ant_version}",
    }
  }

  #define maven symlinking (installs to /usr/local/asfpackages)
  define buildbot_slave::symlink_maven ($maven_version = $title) {
    file {"/home/buildslave/slave/tools/maven/${maven_version}":
      ensure => link,
      target => "/usr/local/asfpackages/maven/${maven_version}",
    }
  }

  #define java symlinking
  define buildbot_slave::symlink_asfpackages ($javaa = $title) {
    file {"/home/buildslave/slave/tools/java/${javaa}":
      ensure => link,
      target => "/usr/local/asfpackages/java/${javaa}",
    }
  }

  file {'/home/buildslave/slave/tools/':
    ensure => 'directory',
    owner  => 'buildslave',
    group  => 'buildslave',
    mode   => '0755',
  }->

  # populate /home/buildslave/slave/tools/ with asf_packages types
  buildbot_slave::mkdir_tools { $tools: }

  package { $buildbot_packages:
    ensure => latest,
  }

  # ant symlinks - populate array, make all symlinks, make latest symlink
  build_slaves::symlink_ant          { $ant: }
  file { '/home/buildslave/slave/tools/ant/latest':
    ensure => link,
    target => '/usr/local/asfpackages/ant/apache-ant-1.9.7',
  }


  # maven symlinks - populate array, make all symlinks, make latest symlink
  buildbot_slave::symlink_maven        { $maven: }
  file { '/home/buildslave/slave/tools/maven/latest2':
    ensure => link,
    target => '/usr/local/asfpackages/maven/apache-maven-2.2.1',
  }
  file { '/home/buildslave/slave/tools/maven/latest':
    ensure => link,
    target => '/usr/local/asfpackages/maven/apache-maven-3.3.9',
  }
  file { '/home/buildslave/slave/tools/maven/latest3':
    ensure => link,
    target => '/usr/local/asfpackages/maven/apache-maven-3.3.9',
  }

  # java symlinks - old java location, new java location, and latest symlinks
  buildbot_slave::symlink_asfpackages  { $java_asfpackages: }
  file { '/home/buildslave/slave/tools/java/latest':
    ensure => link,
    target => '/usr/local/asfpackages/java/jdk1.8.0_102',
  }
  file { '/home/buildslave/slave/tools/java/latest1.5':
    ensure => link,
    target => '/usr/local/asfpackages/java/jdk1.5.0_22-64',
  }
  file { '/home/buildslave/slave/tools/java/latest1.6':
    ensure => link,
    target => '/usr/local/asfpackages/java/jdk1.6.0_45-64',
  }
  file { '/home/buildslave/slave/tools/java/latest1.7':
    ensure => link,
    target => '/usr/local/asfpackages/java/jdk1.7.0_80',
  }
  file { '/home/buildslave/slave/tools/java/latest1.8':
    ensure => link,
    target => '/usr/local/asfpackages/java/jdk1.8.0_102',
  }

}
