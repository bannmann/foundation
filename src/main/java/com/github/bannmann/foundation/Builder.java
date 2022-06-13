package com.github.bannmann.foundation;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.LinkedHashSet;
import java.util.Set;
import java.util.TreeSet;
import java.util.stream.Collectors;
import java.util.stream.Stream;

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

        TreeSet<String> combinableAspects = Stream.of(args)
            .skip(2)
            .collect(Collectors.toCollection(TreeSet::new));

        LinkedHashSet<String> allAspects = new LinkedHashSet<>(combinableAspects);
        allAspects.add("11");

        for (Set<String> selectedCombination : Sets.powerSet(combinableAspects))
        {
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
