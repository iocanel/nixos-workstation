self: super: {
  # Override openjdk with temurin-bin-21 or set openjdk to null
  openjdk = null;
  adoptopenjdk = null;
  jdk = self.temurin-bin-21;
  jre = self.temurin-bin-21;
}
