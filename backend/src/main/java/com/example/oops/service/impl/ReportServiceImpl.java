package com.example.oops.service.impl;

import com.example.oops.entity.Report;
import com.example.oops.repository.ReportRepository;
import com.example.oops.service.ReportService;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class ReportServiceImpl implements ReportService {

    private final ReportRepository repository;

    public ReportServiceImpl(ReportRepository repository) {
        this.repository = repository;
    }

    @Override
    public Report create(Report report) {
        return repository.save(report);
    }

    @Override
    public Optional<Report> findById(Long id) {
        return repository.findById(id);
    }

    @Override
    public List<Report> findAll() {
        return repository.findAll();
    }

    @Override
    public Report update(Long id, Report report) {
        return repository.findById(id).map(existing -> {
            existing.setTitle(report.getTitle());
            existing.setDescription(report.getDescription());
            existing.setStatus(report.getStatus());
            return repository.save(existing);
        }).orElseThrow(() -> new RuntimeException("Report not found: " + id));
    }

    @Override
    public void delete(Long id) {
        repository.deleteById(id);
    }

    @Override
    public List<Report> searchByTitle(String q) {
        return repository.findByTitleContainingIgnoreCase(q == null ? "" : q);
    }
}
