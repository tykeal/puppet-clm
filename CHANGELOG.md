## 2018-04-19 - v2.0.0
### Summary

* Upgrade base supported version to 1.41.0-01

* Please see the CLM [upgrade
  notes](https://help.sonatype.com/iqserver/iq-server-installation/upgrading-the-iq-server/upgrading-the-iq-server-to-version-1.45)
  for moving to 1.45.0 in particular, you should move to 1.44.0 first, perform
  the requested manual operations, then move to 1.45.0 and add the `clm_config`
  entry to allow the upgrade (it can be removed after the upgrade)

* Nexus IQ <1.41.0 is still technically supported. To do so you must fully
  manage the `clm_config` stanza and also set `merge_with_default_config` to
  false. For standard defaults of 1.16.0-02 - 1.40.0 use the following hiera
  configuration:

  ```
  clm::merge_with_default_config: false
  clm::clm_config:
    sonatypeWork: "/srv/clm-server"
    http:
      port: '8070'
      adminPort: '8071'
      requestLog:
        console:
          enabled: false
        file:
          enabled: true
          currentLogFilename: "/var/log/clm-server/request.log"
          archivedLogFilenamePattern: "/var/log/clm-server/request-%d.log.gz"
          archivedFileCount: '5'
    logging:
      level: DEBUG
      loggers:
        com.sonatype.insight.scan: INFO
        eu.medsea.mimeutil.MimeUtil2: INFO
        org.apache.http: INFO
        org.apache.http.wire: ERROR
        org.eclipse.birt.report.engine.layout.pdf.font.FontConfigReader: WARN
        org.eclipse.jetty: INFO
        org.apache.shiro.web.filter.authc.BasicHttpAuthenticationFilter: INFO
      console:
        enabled: true
        threshold: INFO
        logFormat: "%d{'yyyy-MM-dd HH:mm:ss,SSSZ'} %level [%thread] %logger - %msg%n"
      file:
        enabled: true
        threshold: ALL
        currentLogFilename: "/var/log/clm-server/clm-server.log"
        archivedLogFilenamePattern: "/var/log/clm-server/clm-server-%d.log.gz"
        archivedFileCount: '5'
        logFormat: "%d{'yyyy-MM-dd HH:mm:ss,SSSZ'} %level [%thread] %logger - %msg%n"
  ```

## 2018-04-17 - v1.1.0
### Summary

* Support for Debian added thanks to Venushka Perera

## 2016-03-14 - v1.0.0
### Summary

* Sonatype is now releasing initial versions of Nexus IQ without a revision
  number in the bundle name. A fix was put in place to flag if the revision
  number should be used at all

* Bump to version 1.0.0 - While bumping to v0.1.3 would be valid, at this point
  There aren't extra features that are known to be missing so it seems apropos
  to call this as having reached a 1.0.0 status.

## 2015-10-27 - v0.1.2
### Summary

* Sonatype has changed the name of CLM Server starting with version
  1.17.0. This updates the module to handle the package name changes
  cleanly.

## 2015-10-01 - v0.1.1
### Summary

* Fix linting issue missed before initial release

## 2015-10-01 - Initial release v0.1.0
### Summary

* Package finalization
* Documentation finished
