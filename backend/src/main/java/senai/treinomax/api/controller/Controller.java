package senai.treinomax.api.controller;

import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;


@RestController
public class Controller {

    @GetMapping(value = "", produces = "text/html")
    @ResponseBody
    public String status() {
        return """
            <!DOCTYPE html>
            <html lang="en">
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>API Status</title>
                <style>
                    body {
                        height: 100vh;
                        margin: 0;
                        display: flex;
                        justify-content: center;
                        align-items: center;
                        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
                        color: white;
                        background-color: #121212;
                    }
                    .container {
                        text-align: center;
                    }
                    h1 {
                        font-size: 1.5rem;
                        font-weight: 500;
                    }
                </style>
            </head>
            <body>
                <div class="container">
                    <h1>API is running!</h1>
                </div>
            </body>
            </html>
        """;
    }
}