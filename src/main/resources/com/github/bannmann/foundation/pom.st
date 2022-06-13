<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>com.github.bannmann.foundation</groupId>
        <artifactId>parent</artifactId>
        <version>%version%</version>
    </parent>

    <artifactId>%name%</artifactId>
    <packaging>pom</packaging>

    <properties>
        % if (aspects.api && aspects.lombok) %
            <javadoc.sources.directory>${project.build.directory}/generated-sources/delombok-for-javadoc</javadoc.sources.directory>
        % endif %

        % if (aspects.jooq) %
            <jooq.version>3.16.3</jooq.version>
        % endif %

        % if (aspects.kee) %
            <kumuluzee-config-mp.version>1.4.1</kumuluzee-config-mp.version>
            <kumuluzee.version>3.12.1</kumuluzee.version>
        % endif %

        % if (aspects.kee && aspects.mizool) %
            <bannmann-labs.version>0.0.5</bannmann-labs.version>
            <!-- jersey.version must match the one from KumuluzEE -->
            <jersey.version>2.32</jersey.version>
        % endif %

        % if (aspects.lombok) %
            <lombok.core.version>1.18.12</lombok.core.version>
            <lombok.plugin.version>${lombok.core.version}.0</lombok.plugin.version>
        % endif %

        % if (aspects.mizool) %
            <mizool.version>0.48</mizool.version>
        % endif %

        % if (aspects.11) %
            <foundation.toolchains.jdk>11</foundation.toolchains.jdk>
            <maven.compiler.source>11</maven.compiler.source>
            <maven.compiler.target>11</maven.compiler.target>
        % endif %

    </properties>

    <dependencyManagement>
        <dependencies>

            % if (aspects.jooq) %
                <dependency>
                    <groupId>org.jooq</groupId>
                    <artifactId>jooq-parent</artifactId>
                    <version>${jooq.version}</version>
                    <type>pom</type>
                    <scope>import</scope>
                </dependency>
            % endif %

            % if (aspects.kee) %
                <dependency>
                    <groupId>com.kumuluz.ee</groupId>
                    <artifactId>kumuluzee-bom</artifactId>
                    <version>${kumuluzee.version}</version>
                    <type>pom</type>
                    <scope>import</scope>
                </dependency>
                <dependency>
                    <groupId>com.kumuluz.ee.config</groupId>
                    <artifactId>kumuluzee-config-mp</artifactId>
                    <version>${kumuluzee-config-mp.version}</version>
                </dependency>
            % endif %

            % if (aspects.kee && aspects.mizool) %
                <dependency>
                    <groupId>com.github.bannmann.labs</groupId>
                    <artifactId>kumuluzee-errorhandling</artifactId>
                    <version>${bannmann-labs.version}</version>
                </dependency>
                <dependency>
                    <!-- Without this BOM, Mizool's Jersey & KumuluzEE Jersey form a mistuned medley of Jersey jars. -->
                    <groupId>org.glassfish.jersey</groupId>
                    <artifactId>jersey-bom</artifactId>
                    <version>${jersey.version}</version>
                    <type>pom</type>
                    <scope>import</scope>
                </dependency>
            % endif %

            % if (aspects.lombok) %
                <dependency>
                    <groupId>org.projectlombok</groupId>
                    <artifactId>lombok</artifactId>
                    <version>${lombok.core.version}</version>
                    <scope>provided</scope>
                </dependency>
            % endif %

            % if (aspects.mizool) %
                <dependency>
                    <groupId>com.github.mizool</groupId>
                    <artifactId>bom</artifactId>
                    <version>${mizool.version}</version>
                    <type>pom</type>
                    <scope>import</scope>
                </dependency>
            % endif %

        </dependencies>
    </dependencyManagement>

    <dependencies>

        % if (aspects.jooq) %
            <dependency>
                <groupId>org.jooq</groupId>
                <artifactId>jooq</artifactId>
            </dependency>
        % endif %

        % if (aspects.kee && aspects.mizool) %
            <dependency>
                <groupId>com.github.bannmann.labs</groupId>
                <artifactId>kumuluzee-errorhandling</artifactId>
            </dependency>
        % endif %

        % if (aspects.lombok) %
            <dependency>
                <groupId>org.projectlombok</groupId>
                <artifactId>lombok</artifactId>
            </dependency>
        % endif %

        % if (aspects.mizool) %
            <dependency>
                <groupId>com.github.mizool</groupId>
                <artifactId>mizool-core</artifactId>
            </dependency>
        % endif %

    </dependencies>

    <build>
        <pluginManagement>
            <plugins>
                <plugin>
                    <groupId>org.apache.maven.plugins</groupId>
                    <artifactId>maven-javadoc-plugin</artifactId>
                    <version>3.2.0</version>

                    % if (aspects.api) %
                        <configuration>
                            <doclint>none</doclint>
                        </configuration>
                    % endif %

                </plugin>

                % if (aspects.jib) %

                    <plugin>
                        <groupId>com.google.cloud.tools</groupId>
                        <artifactId>jib-maven-plugin</artifactId>
                        <version>3.2.1</version>
                        <configuration>
                            <to>
                                <image>${foundation.jib.image}</image>
                            </to>

                            % if (aspects.kee) %
                                <!--
%!    !%                            recommended minimal run.sh:
%!    !%                                #!/bin/sh
%!    !%                                java \
%!    !%                                    -cp @/app/jib-classpath-file \
%!    !%                                    -Djava.util.logging.config.file=/app/logging.properties \
%!    !%                                    -Dcom.kumuluz.ee.configuration.file=/app/config.yml \
%!    !%                                     @/app/jib-main-class-file
%!    !%                        -->
                                <container>
                                    <entrypoint>sh,/app/run.sh</entrypoint>
                                    <mainClass>com.kumuluz.ee.EeApplication</mainClass>
                                </container>

                                <extraDirectories>
                                    <paths>
                                        <path>src/main/jib</path>
                                        <path>
                                            <!-- For CDI to work, beans.xml must reside with the classes -->
                                            <from>src/main/resources</from>
                                            <into>/app/classes</into>
                                            <includes>**/beans.xml</includes>
                                        </path>
                                    </paths>
                                </extraDirectories>

                                <pluginExtensions>
                                    <pluginExtension>
                                        <implementation>com.google.cloud.tools.jib.maven.extension.layerfilter.JibLayerFilterExtension</implementation>
                                        <configuration implementation="com.google.cloud.tools.jib.maven.extension.layerfilter.Configuration">
                                            <filters>
                                                <!-- Avoid duplicating beans.xml (which we add to /app/classes) -->
                                                <filter>
                                                    <glob>/app/resources/**/beans.xml</glob>
                                                </filter>
                                            </filters>
                                        </configuration>
                                    </pluginExtension>
                                </pluginExtensions>

                            % endif %

                        </configuration>

                        % if (aspects.kee) %
                            <dependencies>
                                <dependency>
                                    <groupId>com.google.cloud.tools</groupId>
                                    <artifactId>jib-layer-filter-extension-maven</artifactId>
                                    <version>0.3.0</version>
                                </dependency>
                            </dependencies>
                        % endif %

                        <executions>
                            <execution>
                                <goals>
                                    <goal>build</goal>
                                </goals>
                                <phase>deploy</phase>
                            </execution>
                        </executions>
                    </plugin>

                    <plugin>
                        <groupId>org.apache.maven.plugins</groupId>
                        <artifactId>maven-deploy-plugin</artifactId>
                        <version>3.0.0-M1</version>
                        <executions>
                            <execution>
                                <id>default-deploy</id>
                                <phase>none</phase>
                            </execution>
                        </executions>
                    </plugin>

                % endif %

                % if (aspects.jooq) %
                    <plugin>
                        <groupId>org.jooq</groupId>
                        <artifactId>jooq-codegen-maven</artifactId>
                        <version>${jooq.version}</version>
                        <dependencies>
                            <dependency>
                                <groupId>org.jooq</groupId>
                                <artifactId>jooq-meta-extensions</artifactId>
                                <version>${jooq.version}</version>
                            </dependency>
                        </dependencies>
                        <executions>
                            <execution>
                                <id>jooq-codegen</id>
                                <goals>
                                    <goal>generate</goal>
                                </goals>
                                <phase>generate-sources</phase>
                                <configuration>
                                    <generator>
                                        <database>
                                            <name>org.jooq.meta.extensions.ddl.DDLDatabase</name>
                                            <properties>
                                                <property>
                                                    <key>scripts</key>
                                                    <value>${project.basedir}/src/main/db/schema.sql</value>
                                                </property>
                                                <property>
                                                    <key>defaultNameCase</key>
                                                    <value>lower</value>
                                                </property>
                                            </properties>
                                        </database>
                                    </generator>
                                </configuration>
                            </execution>
                        </executions>
                    </plugin>
                % endif %

                % if (aspects.kee) %
                    <plugin>
                        <groupId>com.kumuluz.ee</groupId>
                        <artifactId>kumuluzee-maven-plugin</artifactId>
                        <version>${kumuluzee.version}</version>
                    </plugin>
                % endif %

                % if (aspects.lombok) %
                    <plugin>
                        <groupId>org.projectlombok</groupId>
                        <artifactId>lombok-maven-plugin</artifactId>
                        <version>${lombok.plugin.version}</version>
                    </plugin>
                % endif %

            </plugins>
        </pluginManagement>

        <plugins>

            % if (aspects.jib) %
                <plugin>
                    <groupId>com.google.cloud.tools</groupId>
                    <artifactId>jib-maven-plugin</artifactId>
                </plugin>
            % endif %

            % if (aspects.jooq) %
                <plugin>
                    <groupId>org.jooq</groupId>
                    <artifactId>jooq-codegen-maven</artifactId>
                </plugin>
            % endif %

        </plugins>
    </build>

    % if (!aspects.api || aspects.lombok) %
        <profiles>
            <profile>
                <id>release-profile</id>
                <activation>
                    <property>
                        <name>performRelease</name>
                        <value>true</value>
                    </property>
                </activation>
                <build>

                    % if (!aspects.api) %

                        <pluginManagement>
                            <plugins>
                                <plugin>
                                    <groupId>org.apache.maven.plugins</groupId>
                                    <artifactId>maven-javadoc-plugin</artifactId>
                                    <executions>
                                        <execution>
                                            <id>attach-javadocs</id>
                                            <phase>none</phase>
                                        </execution>
                                    </executions>
                                </plugin>
                            </plugins>
                        </pluginManagement>

                    % elseif (aspects.lombok) %

                        <pluginManagement>
                            <plugins>
                                <plugin>
                                    <groupId>org.projectlombok</groupId>
                                    <artifactId>lombok-maven-plugin</artifactId>
                                    <executions>
                                        <execution>
                                            <goals>
                                                <goal>delombok</goal>
                                            </goals>
                                            <phase>prepare-package</phase>
                                            <configuration>
                                                <sourceDirectory>${project.basedir}/src/main/java</sourceDirectory>
                                                <outputDirectory>${javadoc.sources.directory}</outputDirectory>
                                                <addOutputDirectory>false</addOutputDirectory>
                                                <formatPreferences>
                                                    <javaLangAsFQN>skip</javaLangAsFQN>
                                                </formatPreferences>
                                            </configuration>
                                        </execution>
                                    </executions>
                                </plugin>

                                <plugin>
                                    <groupId>org.apache.maven.plugins</groupId>
                                    <artifactId>maven-javadoc-plugin</artifactId>
                                    <configuration>
                                        <sourcepath>${javadoc.sources.directory}</sourcepath>
                                    </configuration>
                                </plugin>
                            </plugins>
                        </pluginManagement>

                        <plugins>
                            <plugin>
                                <groupId>org.projectlombok</groupId>
                                <artifactId>lombok-maven-plugin</artifactId>
                            </plugin>
                        </plugins>

                    % endif %

                </build>
            </profile>
        </profiles>
    % endif %
</project>
