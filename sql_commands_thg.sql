-- Sponsorship effectiveness analysis
SELECT 
    p.interview_score,
    AVG(COALESCE(s.total_sponsorship, 0)) as avg_sponsorship
FROM participant p
LEFT JOIN (
    SELECT participant_id, SUM(sponsor_amount) as total_sponsorship
    FROM sponsorship
    GROUP BY participant_id
) s ON p.participant_id = s.participant_id
GROUP BY p.interview_score
ORDER BY p.interview_score;