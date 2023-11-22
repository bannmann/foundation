package com.github.bannmann.foundation;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.LinkedHashSet;
import java.util.Set;

import org.puretemplate.Loader;
import org.puretemplate.Template;

import com.google.common.collect.ImmutableMap;
import com.google.common.collect.Sets;
import com.google.common.collect.Streams;

public class Builder
{
    public static void main(String[] args) throws IOException
    {
        Template template = new Loader().getTemplate()
            .fromResourceFile(Builder.class, "pom.st")
            .withDelimiters('%', '%')
            .build();

        // TODO turn positional args into explicit CLI options
        Path directory = Path.of(args[0]);
        String version = args[1];

        Set<String> standardAspects = Set.of("gitflow", "lombok", "mizool");

        Set<String> optionalAspects = Set.of("api", "jib", "jooq", "kumuluz", "ossrh", "silverchain");

        // TODO generate everything for JDK 11 and 17 (or 17 and 21?)
        Set<String> jdks = Set.of("11");

        Set<Set<String>> impossibleCombinations = Set.of(Set.of("api", "jib"), Set.of("jib", "ossrh"));

        LinkedHashSet<String> allAspects = new LinkedHashSet<>();
        allAspects.addAll(standardAspects);
        allAspects.addAll(optionalAspects);
        allAspects.addAll(jdks);

        for (Set<String> selectedOptionalAspects : Sets.powerSet(optionalAspects))
        {
            for (String jdk : jdks)
            {
                Set<String> currentAspects = new LinkedHashSet<>();
                Streams.concat(standardAspects.stream(), selectedOptionalAspects.stream())
                    .sorted()
                    .forEachOrdered(currentAspects::add);
                currentAspects.add(jdk);

                // Some optional aspects may be mutually exclusive, or incompatible with certain JDKs
                if (impossibleCombinations.stream()
                    .anyMatch(currentAspects::containsAll))
                {
                    continue;
                }

                String name = String.join("-", currentAspects);

                Path projectDirectory = directory.resolve(name);
                Files.createDirectories(projectDirectory);

                Path pomFile = projectDirectory.resolve("pom.xml");

                template.createContext()
                    .add("name", name)
                    .add("version", version)
                    .add("aspects", buildFlagsMap(allAspects, currentAspects))
                    .render()
                    .intoFile(pomFile);
            }

        }
    }

    private static ImmutableMap<String, Boolean> buildFlagsMap(Iterable<String> allAspects, Set<String> currentAspects)
    {
        ImmutableMap.Builder<String, Boolean> builder = ImmutableMap.builder();
        for (String aspect : allAspects)
        {
            builder.put(aspect, currentAspects.contains(aspect));
        }
        return builder.build();
    }
}
