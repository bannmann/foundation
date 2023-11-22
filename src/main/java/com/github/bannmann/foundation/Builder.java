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

        Set<String> combinableAspects = Set.of("ag", "api", "jib", "jooq", "kee", "lombok", "mizool", "ossrh");

        Set<Set<String>> impossibleCombinations = Set.of(Set.of("api", "jib"), Set.of("jib", "ossrh"));

        LinkedHashSet<String> allAspects = new LinkedHashSet<>(combinableAspects);
        allAspects.add("11");
        // TODO generate everything for JDK 11 and 17 (or 17 and 21?)

        for (Set<String> selectedCombination : Sets.powerSet(combinableAspects))
        {
            if (impossibleCombinations.stream()
                .anyMatch(selectedCombination::containsAll))
            {
                continue;
            }

            Set<String> currentAspects = new LinkedHashSet<>(selectedCombination);
            currentAspects.add("11");

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
