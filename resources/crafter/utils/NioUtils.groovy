package utils

import java.nio.file.Files
import java.nio.file.FileVisitResult
import java.nio.file.Path
import java.nio.file.SimpleFileVisitor
import java.nio.file.attribute.BasicFileAttributes

import static java.nio.file.FileVisitResult.*
import static java.nio.file.StandardCopyOption.*

class NioUtils {

  /**
   * Copies the source directory recursively to the target directory, preserving file attributes.
   */
  static def copyDirectory(source, target) {
    Files.walkFileTree(source, new SimpleFileVisitor<Path>() {

      @Override
      public FileVisitResult preVisitDirectory(Path dir, BasicFileAttributes attrs) {
        Files.copy(dir, target.resolve(source.relativize(dir)), COPY_ATTRIBUTES)
        return CONTINUE;
      }

      @Override
      public FileVisitResult visitFile(Path file, BasicFileAttributes attrs) throws IOException {
        Files.copy(file, target.resolve(source.relativize(file)), COPY_ATTRIBUTES)
        return CONTINUE;
      }

    })
  }

  /**
   * Deletes the specified directory {@code Path} recursively.
   */
  static def deleteDirectory(directory) {
    if (Files.exists(directory)) {
      Files.walkFileTree(directory, new SimpleFileVisitor<Path>() {

        @Override
        public FileVisitResult visitFile(Path file, BasicFileAttributes attrs) throws IOException {
          Files.delete(file);
          return CONTINUE;
        }

        @Override
        public FileVisitResult postVisitDirectory(Path dir, IOException exc) throws IOException {
          Files.delete(dir);
          return CONTINUE;
        }

      })
    }
  }

}
