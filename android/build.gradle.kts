import com.android.build.gradle.LibraryExtension
import org.gradle.kotlin.dsl.configure
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    configurations.configureEach {
        exclude(group = "androidx.work", module = "work-runtime-ktx")
    }
}

/**
 * Fix for image_gallery_saver:
 * JVM target mismatch: Java=1.8, Kotlin=21 -> force Kotlin to 1.8 (and keep Java 1.8)
 */
subprojects {
    if (name == "image_gallery_saver") {

        // Keep/ensure Android library config exists (и твой namespace фикс, если он у тебя был)
        plugins.withId("com.android.library") {
            extensions.configure<LibraryExtension> {
                if (namespace == null) {
                    namespace = "com.example.imagegallerysaver"
                }
                compileOptions {
                    sourceCompatibility = JavaVersion.VERSION_1_8
                    targetCompatibility = JavaVersion.VERSION_1_8
                }
            }
        }

        // Force Kotlin compile JVM target to 1.8
        plugins.withId("org.jetbrains.kotlin.android") {
            tasks.withType<KotlinCompile>().configureEach {
                kotlinOptions.jvmTarget = "1.8"
            }
        }
        plugins.withId("kotlin-android") {
            tasks.withType<KotlinCompile>().configureEach {
                kotlinOptions.jvmTarget = "1.8"
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
