package com.example.oops.controller;

import com.example.oops.dto.ReportRequest;
import com.example.oops.dto.ReportResponse;
import com.example.oops.entity.Report;
import com.example.oops.service.ReportService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/reports")
public class ReportController {

    private final ReportService service;

    public ReportController(ReportService service) {
        this.service = service;
    }

    @PostMapping
    public ResponseEntity<ReportResponse> create(@Valid @RequestBody ReportRequest request) {
        Report report = new Report(request.getTitle(), request.getDescription(), request.getStatus());
        Report saved = service.create(report);
        ReportResponse res = toResponse(saved);
        return ResponseEntity.created(URI.create("/api/reports/" + res.getId())).body(res);
    }

    @GetMapping
    public List<ReportResponse> list() {
        return service.findAll().stream().map(this::toResponse).collect(Collectors.toList());
    }

    @GetMapping("/{id}")
    public ResponseEntity<ReportResponse> getOne(@PathVariable Long id) {
        return service.findById(id).map(r -> ResponseEntity.ok(toResponse(r)))
                .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<ReportResponse> update(@PathVariable Long id, @Valid @RequestBody ReportRequest request) {
        try {
            Report toUpdate = new Report(request.getTitle(), request.getDescription(), request.getStatus());
            Report updated = service.update(id, toUpdate);
            return ResponseEntity.ok(toResponse(updated));
        } catch (RuntimeException ex) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/search")
    public List<ReportResponse> search(@RequestParam(name = "q", required = false) String q) {
        return service.searchByTitle(q).stream().map(this::toResponse).collect(Collectors.toList());
    }

    private ReportResponse toResponse(Report r) {
        ReportResponse resp = new ReportResponse();
        resp.setId(r.getId());
        resp.setTitle(r.getTitle());
        resp.setDescription(r.getDescription());
        resp.setStatus(r.getStatus());
        resp.setCreatedAt(r.getCreatedAt());
        return resp;
    }
}
