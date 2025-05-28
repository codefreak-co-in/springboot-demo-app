package org.codefreak.todo.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("todo")
public class TodoController {

    private static final Logger logger = LoggerFactory.getLogger(TodoController.class);

    @GetMapping
    public ResponseEntity<?> getTodo() {
        logger.info("getTodo log");
        List<String> todos = List.of("Todo 1", "Todo2");
        logger.info(todos.toString());
        return ResponseEntity.ok(todos);
    }

    @GetMapping(value = "/health")
    public ResponseEntity<?> health() {
        logger.info("health log");
        return new ResponseEntity<>("health", HttpStatus.OK);
    }

}
