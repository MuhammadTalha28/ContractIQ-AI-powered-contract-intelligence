'use client'

import { useState, useEffect } from 'react'
import { useParams, useRouter } from 'next/navigation'
import axios from 'axios'
import Link from 'next/link'

interface Clause {
  name: string
  description: string
  type: string
}

interface ContractAnalysis {
  contract_id: string
  filename: string
  summary: string
  clauses: Clause[]
  clauses_count: number
  status: string
  uploaded_at: string
}

export default function ContractDetailPage() {
  const params = useParams()
  const router = useRouter()
  const contractId = params.id as string
  const [analysis, setAnalysis] = useState<ContractAnalysis | null>(null)
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    fetchAnalysis()
  }, [contractId])

  const fetchAnalysis = async () => {
    try {
      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'https://YOUR_API_GATEWAY_URL/dev'
      // Fetch contract details from DynamoDB via API
      const response = await axios.get(`${apiUrl}/contracts/${contractId}`)
      const data = typeof response.data === 'string' ? JSON.parse(response.data) : response.data
      setAnalysis(data)
    } catch (error) {
      console.error('Failed to fetch analysis:', error)
      // Fallback: try to get from contracts list
      try {
        const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'https://YOUR_API_GATEWAY_URL/dev'
        const contractsResponse = await axios.get(`${apiUrl}/contracts`)
        const contract = contractsResponse.data.find((c: any) => c.id === contractId)
        if (contract) {
          setAnalysis({
            contract_id: contract.id,
            filename: contract.filename,
            summary: contract.summary || '',
            clauses: [],
            clauses_count: contract.clausesCount || 0,
            status: contract.status,
            uploaded_at: contract.uploadedAt
          })
        }
      } catch (e) {
        console.error('Failed to fetch from list:', e)
      }
    } finally {
      setIsLoading(false)
    }
  }

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gray-50 py-12 px-4">
        <div className="max-w-4xl mx-auto">
          <p className="text-gray-600">Loading analysis...</p>
        </div>
      </div>
    )
  }

  if (!analysis) {
    return (
      <div className="min-h-screen bg-gray-50 py-12 px-4">
        <div className="max-w-4xl mx-auto">
          <p className="text-gray-600">Analysis not found</p>
          <Link href="/dashboard" className="text-primary-600 hover:text-primary-700">
            ← Back to Dashboard
          </Link>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50 py-12 px-4">
      <div className="max-w-4xl mx-auto">
        <div className="mb-6">
          <Link href="/dashboard" className="text-primary-600 hover:text-primary-700 mb-4 inline-block">
            ← Back to Dashboard
          </Link>
          <h1 className="text-3xl font-bold text-gray-900 mt-4">{analysis.filename}</h1>
          <p className="text-sm text-gray-500 mt-2">
            Uploaded: {new Date(analysis.uploaded_at).toLocaleString()}
          </p>
        </div>

        <div className="bg-white rounded-lg shadow-lg p-8">
          <h2 className="text-2xl font-semibold text-gray-900 mb-6">Contract Analysis</h2>

          {analysis.summary && (
            <div className="mb-8">
              <h3 className="text-lg font-semibold text-gray-800 mb-3">Summary</h3>
              <p className="text-gray-700 leading-relaxed">{analysis.summary}</p>
            </div>
          )}

          <div className="mb-8">
            <h3 className="text-lg font-semibold text-gray-800 mb-4">
              Extracted Clauses ({analysis.clauses_count})
            </h3>
            {analysis.clauses_count > 0 ? (
              <div className="space-y-4">
                {analysis.clauses.map((clause, index) => (
                  <div key={index} className="border-l-4 border-primary-500 pl-4 py-2">
                    <h4 className="font-semibold text-gray-900">{clause.name}</h4>
                    <p className="text-gray-600 text-sm mt-1">{clause.description}</p>
                    <span className="inline-block mt-2 px-2 py-1 bg-gray-100 text-gray-700 text-xs rounded">
                      {clause.type}
                    </span>
                  </div>
                ))}
              </div>
            ) : (
              <p className="text-gray-500">No clauses extracted yet. Analysis may still be processing.</p>
            )}
          </div>

          <div className="mt-8 pt-6 border-t border-gray-200">
            <p className="text-sm text-gray-500">
              Status: <span className="font-medium text-gray-700">{analysis.status}</span>
            </p>
          </div>
        </div>
      </div>
    </div>
  )
}

