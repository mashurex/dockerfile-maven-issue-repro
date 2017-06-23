# Dockerfile Maven Repro Sample

This project is setup to reproduce [Issue #25](https://github.com/spotify/dockerfile-maven/issues/25) from the [dockerfile-maven](https://github.com/spotify/dockerfile-maven) project.

## Root Cause / Explanation
[Matt Brown](https://github.com/mattnworb) [suggested](https://github.com/spotify/dockerfile-maven/issues/25#issuecomment-310667051) the 
`**` at the top of the old `.dockerignore` was keeping the `Dockerfile` from being sent in the context. Further testing proved this out.
Removing the `**` ignore everything line immediately made the plugin work just fine. 🤦

### Old .dockerignore
```
** <--- This was the issue
!target/application.jar
```

The `docker` client interprets this to ignore everything except the `target/application.jar` but still implicitly includes 
the `Dockerfile`. The `dockerfile-maven` plugin process interprets this more explicitly, 
as in it ignores *everything* but the single `target/application.jar`, including the `Dockerfile` 

### Updated .dockerignore
If for some reason you wanted to keep the `**` ignore everything line, you could create a file like so:
```
**
!Dockerfile
!target/application.jar
```

Otherwise, just remove the `**` and move to more explicit ignores.

## My Test Environment

- **OS:** MacOS Sierra 10.12.5
- **Docker:** 17.03.1-ce, build c6d412e
- **Java:** Oracle JDK 1.8.0_112-b16 x86_64
- **Maven:** 3.3.9 and 3.5.0 (using Maven Wrapper)

## Building without Dockerfile Maven
### Build the Jar
`./mvnw clean package`

### Test the Jar
`java -jar target/application.jar` should output `Hello World`

### Build and Run the Docker Image
`docker build -t ashurex/hello-world:latest .`

`docker run ashurex/hello-world:latest` should output `Hello World`

## Building with Dockerfile Maven
Use the **docker** profile to include the *dockerfile-maven* project during the package phase like so: 

`./mvnw -Pdocker clean package`

### Expected Result
```shell
[INFO] Scanning for projects...
[INFO] 
[INFO] ------------------------------------------------------------------------
[INFO] Building maven-spotify-docker-repro 1.0.0-SNAPSHOT
[INFO] ------------------------------------------------------------------------
[INFO] 
[INFO] --- maven-clean-plugin:2.5:clean (default-clean) @ maven-spotify-docker-repro ---
[INFO] Deleting /path/to/project/MavenSpotifyDockerRepro/target
[INFO] 
[INFO] --- maven-resources-plugin:2.6:resources (default-resources) @ maven-spotify-docker-repro ---
[WARNING] Using platform encoding (UTF-8 actually) to copy filtered resources, i.e. build is platform dependent!
[INFO] Copying 0 resource
[INFO] 
[INFO] --- maven-compiler-plugin:3.1:compile (default-compile) @ maven-spotify-docker-repro ---
[INFO] Changes detected - recompiling the module!
[WARNING] File encoding has not been set, using platform encoding UTF-8, i.e. build is platform dependent!
[INFO] Compiling 1 source file to /path/to/project/MavenSpotifyDockerRepro/target/classes
[INFO] 
[INFO] --- maven-resources-plugin:2.6:testResources (default-testResources) @ maven-spotify-docker-repro ---
[WARNING] Using platform encoding (UTF-8 actually) to copy filtered resources, i.e. build is platform dependent!
[INFO] skip non existing resourceDirectory /path/to/project/MavenSpotifyDockerRepro/src/test/resources
[INFO] 
[INFO] --- maven-compiler-plugin:3.1:testCompile (default-testCompile) @ maven-spotify-docker-repro ---
[INFO] Nothing to compile - all classes are up to date
[INFO] 
[INFO] --- maven-surefire-plugin:2.12.4:test (default-test) @ maven-spotify-docker-repro ---
[INFO] No tests to run.
[INFO] 
[INFO] --- maven-jar-plugin:3.0.2:jar (default-jar) @ maven-spotify-docker-repro ---
[INFO] Building jar: /path/to/project/MavenSpotifyDockerRepro/target/application.jar
[INFO] 
[INFO] --- dockerfile-maven-plugin:1.3.0:build (default) @ maven-spotify-docker-repro ---
[INFO] Building Docker context /path/to/project/MavenSpotifyDockerRepro
[INFO] 
[INFO] Image will be built as ashurex/hello-world:latest
[INFO] 
[WARNING] An attempt failed, will retry 1 more times
org.apache.maven.plugin.MojoExecutionException: Could not build image
        at com.spotify.plugin.dockerfile.BuildMojo.buildImage(BuildMojo.java:164)
        at com.spotify.plugin.dockerfile.BuildMojo.execute(BuildMojo.java:95)
        at com.spotify.plugin.dockerfile.AbstractDockerMojo.tryExecute(AbstractDockerMojo.java:219)
        at com.spotify.plugin.dockerfile.AbstractDockerMojo.execute(AbstractDockerMojo.java:208)
        at org.apache.maven.plugin.DefaultBuildPluginManager.executeMojo(DefaultBuildPluginManager.java:134)
        at org.apache.maven.lifecycle.internal.MojoExecutor.execute(MojoExecutor.java:208)
        at org.apache.maven.lifecycle.internal.MojoExecutor.execute(MojoExecutor.java:154)
        at org.apache.maven.lifecycle.internal.MojoExecutor.execute(MojoExecutor.java:146)
        at org.apache.maven.lifecycle.internal.LifecycleModuleBuilder.buildProject(LifecycleModuleBuilder.java:117)
        at org.apache.maven.lifecycle.internal.LifecycleModuleBuilder.buildProject(LifecycleModuleBuilder.java:81)
        at org.apache.maven.lifecycle.internal.builder.singlethreaded.SingleThreadedBuilder.build(SingleThreadedBuilder.java:51)
        at org.apache.maven.lifecycle.internal.LifecycleStarter.execute(LifecycleStarter.java:128)
        at org.apache.maven.DefaultMaven.doExecute(DefaultMaven.java:309)
        at org.apache.maven.DefaultMaven.doExecute(DefaultMaven.java:194)
        at org.apache.maven.DefaultMaven.execute(DefaultMaven.java:107)
        at org.apache.maven.cli.MavenCli.execute(MavenCli.java:993)
        at org.apache.maven.cli.MavenCli.doMain(MavenCli.java:345)
        at org.apache.maven.cli.MavenCli.main(MavenCli.java:191)
        at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
        at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62)
        at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
        at java.lang.reflect.Method.invoke(Method.java:498)
        at org.codehaus.plexus.classworlds.launcher.Launcher.launchEnhanced(Launcher.java:289)
        at org.codehaus.plexus.classworlds.launcher.Launcher.launch(Launcher.java:229)
        at org.codehaus.plexus.classworlds.launcher.Launcher.mainWithExitCode(Launcher.java:415)
        at org.codehaus.plexus.classworlds.launcher.Launcher.main(Launcher.java:356)
        at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
        at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62)
        at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
        at java.lang.reflect.Method.invoke(Method.java:498)
        at org.apache.maven.wrapper.BootstrapMainStarter.start(BootstrapMainStarter.java:39)
        at org.apache.maven.wrapper.WrapperExecutor.execute(WrapperExecutor.java:122)
        at org.apache.maven.wrapper.MavenWrapperMain.main(MavenWrapperMain.java:50)
Caused by: com.spotify.docker.client.exceptions.DockerRequestException: Request error: POST unix://localhost:80/build?pull=true&t=ashurex%2Fhello-world%3Alatest: 500, body: {"message":"Cannot locate specified Dockerfile: Dockerfile"}

        at com.spotify.docker.client.DefaultDockerClient.propagate(DefaultDockerClient.java:2387)
        at com.spotify.docker.client.DefaultDockerClient.request(DefaultDockerClient.java:2337)
        at com.spotify.docker.client.DefaultDockerClient.build(DefaultDockerClient.java:1376)
        at com.spotify.docker.client.DefaultDockerClient.build(DefaultDockerClient.java:1348)
        at com.spotify.plugin.dockerfile.BuildMojo.buildImage(BuildMojo.java:157)
        ... 32 more
Caused by: com.spotify.docker.client.shaded.javax.ws.rs.InternalServerErrorException: HTTP 500 Internal Server Error
        at org.glassfish.jersey.client.JerseyInvocation.convertToException(JerseyInvocation.java:1020)
        at org.glassfish.jersey.client.JerseyInvocation.translate(JerseyInvocation.java:816)
        at org.glassfish.jersey.client.JerseyInvocation.access$700(JerseyInvocation.java:92)
        at org.glassfish.jersey.client.JerseyInvocation$5.completed(JerseyInvocation.java:773)
        at org.glassfish.jersey.client.ClientRuntime.processResponse(ClientRuntime.java:198)
        at org.glassfish.jersey.client.ClientRuntime.access$300(ClientRuntime.java:79)
        at org.glassfish.jersey.client.ClientRuntime$2.run(ClientRuntime.java:180)
        at org.glassfish.jersey.internal.Errors$1.call(Errors.java:271)
        at org.glassfish.jersey.internal.Errors$1.call(Errors.java:267)
        at org.glassfish.jersey.internal.Errors.process(Errors.java:315)
        at org.glassfish.jersey.internal.Errors.process(Errors.java:297)
        at org.glassfish.jersey.internal.Errors.process(Errors.java:267)
        at org.glassfish.jersey.process.internal.RequestScope.runInScope(RequestScope.java:340)
        at org.glassfish.jersey.client.ClientRuntime$3.run(ClientRuntime.java:210)
        at java.util.concurrent.Executors$RunnableAdapter.call(Executors.java:511)
        at java.util.concurrent.FutureTask.run(FutureTask.java:266)
        at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1142)
        at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:617)
        at java.lang.Thread.run(Thread.java:745)
[INFO] Building Docker context /path/to/project/MavenSpotifyDockerRepro
[INFO] 
[INFO] Image will be built as ashurex/hello-world:latest
[INFO] 
[INFO] ------------------------------------------------------------------------
[INFO] BUILD FAILURE
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 3.117 s
[INFO] Finished at: 2017-06-22T13:34:32-07:00
[INFO] Final Memory: 34M/504M
[INFO] ------------------------------------------------------------------------
[ERROR] Failed to execute goal com.spotify:dockerfile-maven-plugin:1.3.0:build (default) on project maven-spotify-docker-repro: Could not build image: Request error: POST unix://localhost:80/build?pull=true&t=ashurex%2Fhello-world%3Alatest: 500, body: {"message":"Cannot locate specified Dockerfile: Dockerfile"}: HTTP 500 Internal Server Error -> [Help 1]
[ERROR] 
[ERROR] To see the full stack trace of the errors, re-run Maven with the -e switch.
[ERROR] Re-run Maven using the -X switch to enable full debug logging.
[ERROR] 
[ERROR] For more information about the errors and possible solutions, please read the following articles:
[ERROR] [Help 1] http://cwiki.apache.org/confluence/display/MAVEN/MojoExecutionException
```
