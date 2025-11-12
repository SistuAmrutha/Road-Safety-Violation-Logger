package com.example.oops.service;

import com.example.oops.entity.Report;

import java.util.List;
import java.util.Optional;

public interface ReportService {
    Report create(Report report);
    Optional<Report> findById(Long id);
    List<Report> findAll();
    Report update(Long id, Report report);
    void delete(Long id);
    List<Report> searchByTitle(String q);
}
