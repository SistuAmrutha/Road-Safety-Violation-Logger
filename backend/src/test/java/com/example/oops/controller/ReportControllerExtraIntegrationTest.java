package com.example.oops.controller;

import com.example.oops.dto.ReportResponse;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.*;
import org.springframework.web.client.HttpClientErrorException;

import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class ReportControllerExtraIntegrationTest {

    @Autowired
    private TestRestTemplate restTemplate;

    @Test
    public void updateReport_shouldModifyTitle() {
        Map<String, Object> req = Map.of(
                "title", "ToUpdate",
                "description", "before",
                "status", "OPEN"
        );
        ResponseEntity<ReportResponse> postResp = restTemplate.postForEntity("/api/reports", req, ReportResponse.class);
        assertThat(postResp.getStatusCode().is2xxSuccessful()).isTrue();
        ReportResponse created = postResp.getBody();
        assertThat(created).isNotNull();

        Map<String, Object> update = Map.of(
                "title", "Updated Title",
                "description", "after",
                "status", "CLOSED"
        );
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(update, headers);

        ResponseEntity<ReportResponse> putResp = restTemplate.exchange("/api/reports/{id}", HttpMethod.PUT, entity, ReportResponse.class, created.getId());
        assertThat(putResp.getStatusCode().is2xxSuccessful()).isTrue();
        ReportResponse updated = putResp.getBody();
        assertThat(updated).isNotNull();
        assertThat(updated.getTitle()).isEqualTo("Updated Title");
        assertThat(updated.getStatus()).isEqualTo("CLOSED");
    }

    @Test
    public void deleteReport_shouldReturnNotFoundAfterDeletion() {
        Map<String, Object> req = Map.of(
                "title", "ToDelete",
                "description", "delete me",
                "status", "OPEN"
        );
        ResponseEntity<ReportResponse> postResp = restTemplate.postForEntity("/api/reports", req, ReportResponse.class);
        assertThat(postResp.getStatusCode().is2xxSuccessful()).isTrue();
        ReportResponse created = postResp.getBody();
        assertThat(created).isNotNull();

        restTemplate.delete("/api/reports/{id}", created.getId());

        // Expect 404 when fetching deleted resource
        assertThatThrownBy(() -> restTemplate.getForEntity("/api/reports/{id}", ReportResponse.class, created.getId()))
                .isInstanceOf(HttpClientErrorException.class)
                .hasMessageContaining("404");
    }

    @Test
    public void searchReports_shouldReturnMatching() {
        String uniqueTitle = "UniqueSearchTitle-" + System.currentTimeMillis();
        Map<String, Object> req = Map.of(
                "title", uniqueTitle,
                "description", "search test",
                "status", "OPEN"
        );
        ResponseEntity<ReportResponse> postResp = restTemplate.postForEntity("/api/reports", req, ReportResponse.class);
        assertThat(postResp.getStatusCode().is2xxSuccessful()).isTrue();
        ReportResponse created = postResp.getBody();
        assertThat(created).isNotNull();

        ResponseEntity<ReportResponse[]> searchResp = restTemplate.getForEntity("/api/reports/search?q={q}", ReportResponse[].class, uniqueTitle.substring(0, 10));
        assertThat(searchResp.getStatusCode().is2xxSuccessful()).isTrue();
        ReportResponse[] results = searchResp.getBody();
        assertThat(results).isNotNull();
        boolean found = false;
        for (ReportResponse r : results) {
            if (r.getId() != null && r.getId().equals(created.getId())) {
                found = true; break;
            }
        }
        assertThat(found).isTrue();
    }
}
