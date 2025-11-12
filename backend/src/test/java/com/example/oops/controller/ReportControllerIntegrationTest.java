package com.example.oops.controller;

import com.example.oops.dto.ReportResponse;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.ResponseEntity;

import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class ReportControllerIntegrationTest {

    @Autowired
    private TestRestTemplate restTemplate;

    @Test
    public void postAndGetReports_shouldReturnCreatedReport() {
        // create a new report via POST
        Map<String, Object> req = Map.of(
                "title", "ITest - ci",
                "description", "integration test",
                "status", "OPEN"
        );

        ResponseEntity<ReportResponse> postResp = restTemplate.postForEntity("/api/reports", req, ReportResponse.class);
        assertThat(postResp.getStatusCode().is2xxSuccessful()).isTrue();
        ReportResponse created = postResp.getBody();
        assertThat(created).isNotNull();
        assertThat(created.getId()).isNotNull();

        // list and ensure at least one report exists and matches created title
        ResponseEntity<ReportResponse[]> listResp = restTemplate.getForEntity("/api/reports", ReportResponse[].class);
        assertThat(listResp.getStatusCode().is2xxSuccessful()).isTrue();
        ReportResponse[] reports = listResp.getBody();
        assertThat(reports).isNotNull().isNotEmpty();

        boolean found = false;
        for (ReportResponse r : reports) {
            if (r.getId() != null && r.getId().equals(created.getId())) {
                found = true;
                break;
            }
        }
        assertThat(found).isTrue();
    }
}
