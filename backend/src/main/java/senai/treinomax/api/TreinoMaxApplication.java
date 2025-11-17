package senai.treinomax.api;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class TreinoMaxApplication {

	public static void main(String[] args) {
		// Log environment variables
		System.out.println("========================================");
		System.out.println("====== ENVIRONMENT VARIABLES ======");
		System.out.println("========================================");
		System.out.println("SMTP_HOST: " + System.getenv("SMTP_HOST"));
		System.out.println("SMTP_PORT: " + System.getenv("SMTP_PORT"));
		System.out.println("SMTP_USERNAME: " + System.getenv("SMTP_USERNAME"));
		System.out.println("SMTP_PASSWORD: " + System.getenv("SMTP_PASSWORD"));
		System.out.println("JWT_SECRET: " + System.getenv("JWT_SECRET"));
		System.out.println("SPRING_DATASOURCE_URL: " + System.getenv("SPRING_DATASOURCE_URL"));
		System.out.println("SPRING_DATASOURCE_USERNAME: " + System.getenv("SPRING_DATASOURCE_USERNAME"));
		System.out.println("SPRING_DATASOURCE_PASSWORD: " + System.getenv("SPRING_DATASOURCE_PASSWORD"));
		System.out.println("SPRING_PROFILES_ACTIVE: " + System.getenv("SPRING_PROFILES_ACTIVE"));
		System.out.println("CORS_ALLOWED_ORIGINS: " + System.getenv("CORS_ALLOWED_ORIGINS"));
		System.out.println("========================================");
		
		SpringApplication.run(TreinoMaxApplication.class, args);
	}

}